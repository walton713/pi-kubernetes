using System.Data.Common;
using FluentValidation;
using FluentValidation.AspNetCore;
using HomeApi.Database;
using HomeApi.Database.Repositories;
using HomeApi.Models.LocalWeatherObservations;
using HomeApi.Validators;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Infrastructure;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Newtonsoft.Json.Serialization;
using OpenTelemetry.Metrics;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers()
    .AddNewtonsoftJson(setupAction =>
        setupAction.SerializerSettings.ContractResolver = new CamelCasePropertyNamesContractResolver())
    .ConfigureApiBehaviorOptions(setupAction =>
    {
        setupAction.InvalidModelStateResponseFactory = context =>
        {
            var problemDetailsFactory = context.HttpContext.RequestServices.GetService<ProblemDetailsFactory>();
            var validationProblemDetails =
                problemDetailsFactory!.CreateValidationProblemDetails(context.HttpContext, context.ModelState);
            validationProblemDetails.Detail = "See the errors property for additional details";
            validationProblemDetails.Instance = context.HttpContext.Request.Path;
            validationProblemDetails.Status = StatusCodes.Status422UnprocessableEntity;
            validationProblemDetails.Title = "One or more validation errors occurred.";

            return new UnprocessableEntityObjectResult(validationProblemDetails)
            {
                ContentTypes = { "application/problem+json" }
            };
        };
    });

builder.Services.AddFluentValidationAutoValidation()
    .AddFluentValidationClientsideAdapters();

if (builder.Environment.IsDevelopment())
{
    builder.Services.AddSingleton<DbConnection>(container =>
    {
        var connection = new SqliteConnection("DataSource=:memory:");
        connection.Open();
        return connection;
    });

    builder.Services.AddDbContext<ApiDbContext>((container, options) =>
    {
        var connection = container.GetRequiredService<DbConnection>();
        options.UseSqlite(connection);
    });
}
else
{
    var connectionString = Environment.GetEnvironmentVariable("DB_CONNECTION") ?? throw new ArgumentException("DB_CONNECTION environment variable is required");
    builder.Services.AddDbContext<ApiDbContext>(options =>
    {
        options.UseMySql(
            connectionString,
            ServerVersion.AutoDetect(connectionString));
    });
}

builder.Services.AddScoped<ILocalWeatherObservationRepository, LocalWeatherObservationRepository>();
builder.Services.AddScoped<IValidator<AddEditLocalWeatherObservationDto>, AddLocalWeatherObservationDtoValidator>();

builder.Services.AddAutoMapper(cfg => { }, AppDomain.CurrentDomain.GetAssemblies());

builder.Services.AddHealthChecks()
    .AddDbContextCheck<ApiDbContext>("Database", HealthStatus.Degraded);

builder.Services.AddOpenTelemetry()
    .WithMetrics(b =>
    {
        b.AddPrometheusExporter();
        b.AddMeter("Microsoft.AspNetCore.Hosting",
                   "Microsoft.AspNetCore.Server.Kestrel");
        b.AddView("http.server.request.duration",
            new ExplicitBucketHistogramConfiguration
            {
                Boundaries = [0, 0.005, 0.01, 0.025, 0.05, 0.075, 0.1, 0.25, 0.5, 0.75, 1, 2.5, 5, 7.5, 10]
            });
    });

if (builder.Environment.IsDevelopment())
{
    builder.Services.AddCors(options =>
    {
        options.AddPolicy("MyCorsPolicy", builder =>
        {
            builder.WithOrigins("http://localhost:4200")
                .AllowAnyHeader()
                .AllowAnyMethod();
        });
    });
}
else
{
    builder.Services.AddCors(options =>
    {
        options.AddPolicy("MyCorsPolicy", builder =>
        {
            builder.WithOrigins("http://home.local")
                .AllowAnyHeader()
                .AllowAnyMethod();
        });
    });
}

var app = builder.Build();

app.MapPrometheusScrapingEndpoint();
app.MapHealthChecks("/health/ready", new HealthCheckOptions
    {
        Predicate = check => check.Tags.Contains("ready")
    });
app.MapHealthChecks("/health/live", new HealthCheckOptions
    {
        Predicate = _ => false
    });

app.MapControllers();

if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();

    using var scope = app.Services.CreateScope();

    try
    {
        var context = scope.ServiceProvider.GetRequiredService<ApiDbContext>();
        await context.Database.EnsureDeletedAsync();
        await context.Database.EnsureCreatedAsync();
        Data.SeedDatabase(context);
    }
    catch (Exception e)
    {
        Console.WriteLine(e);
        throw;
    }
}

app.UseCors("MyCorsPolicy");

await app.RunAsync();

public partial class Program { }

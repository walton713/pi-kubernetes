using HomeApi.Database.Entities;

namespace HomeApi.Database;

public static class Data
{
    public static void SeedDatabase(ApiDbContext context)
    {
        var now = DateTimeOffset.UtcNow;
        var localWeatherObservations = new List<LocalWeatherObservation>
        {
            new()
            {
                Id = Guid.NewGuid(),
                Date = DateOnly.FromDateTime(now.Date),
                Created = now,
                Updated = now,
                Precipitation = 0,
                TracePrecipitation = false,
                Snow = 0,
                TraceSnow = false
            },
            new()
            {
                Id = Guid.NewGuid(),
                Date = DateOnly.FromDateTime(now.Date).AddDays(-1),
                Created = now,
                Updated = now,
                Precipitation = new decimal(0.05),
                TracePrecipitation = false,
                Snow = 0,
                TraceSnow = false
            },
            new()
            {
                Id = Guid.NewGuid(),
                Date = DateOnly.FromDateTime(now.Date).AddDays(-2),
                Created = now,
                Updated = now,
                Precipitation = new decimal(1.25),
                TracePrecipitation = false,
                Snow = 0,
                TraceSnow = false
            },
            new()
            {
                Id = Guid.NewGuid(),
                Date = DateOnly.FromDateTime(now.Date).AddDays(-3),
                Created = now,
                Updated = now,
                Precipitation = 0,
                TracePrecipitation = false,
                Snow = 0,
                TraceSnow = false
            },
            new()
            {
                Id = Guid.NewGuid(),
                Date = DateOnly.FromDateTime(now.Date).AddDays(-4),
                Created = now,
                Updated = now,
                Precipitation = new decimal(0.05),
                TracePrecipitation = false,
                Snow = 1,
                TraceSnow = false
            },
            new()
            {
                Id = Guid.NewGuid(),
                Date = DateOnly.FromDateTime(now.Date).AddDays(-5),
                Created = now,
                Updated = now,
                Precipitation = 0,
                TracePrecipitation = true,
                Snow = 0,
                TraceSnow = true
            },
            new()
            {
                Id = Guid.NewGuid(),
                Date = DateOnly.FromDateTime(now.Date).AddDays(-6),
                Created = now,
                Updated = now,
                Precipitation = new decimal(0.05),
                TracePrecipitation = false,
                Snow = 0,
                TraceSnow = false
            },
            new()
            {
                Id = Guid.NewGuid(),
                Date = DateOnly.FromDateTime(now.Date).AddDays(-7),
                Created = now,
                Updated = now,
                Precipitation = new decimal(1.25),
                TracePrecipitation = false,
                Snow = 0,
                TraceSnow = false
            },
            new()
            {
                Id = Guid.NewGuid(),
                Date = DateOnly.FromDateTime(now.Date).AddDays(-8),
                Created = now,
                Updated = now,
                Precipitation = 0,
                TracePrecipitation = false,
                Snow = 0,
                TraceSnow = false
            },
            new()
            {
                Id = Guid.NewGuid(),
                Date = DateOnly.FromDateTime(now.Date).AddDays(-9),
                Created = now,
                Updated = now,
                Precipitation = new decimal(0.05),
                TracePrecipitation = false,
                Snow = 1,
                TraceSnow = false
            },
            new()
            {
                Id = Guid.NewGuid(),
                Date = DateOnly.FromDateTime(now.Date).AddDays(-10),
                Created = now,
                Updated = now,
                Precipitation = 0,
                TracePrecipitation = true,
                Snow = 0,
                TraceSnow = true
            },
            new()
            {
                Id = Guid.NewGuid(),
                Date = DateOnly.FromDateTime(now.Date).AddDays(-11),
                Created = now,
                Updated = now,
                Precipitation = new decimal(0.05),
                TracePrecipitation = false,
                Snow = 0,
                TraceSnow = false
            },
            new()
            {
                Id = Guid.NewGuid(),
                Date = DateOnly.FromDateTime(now.Date).AddDays(-12),
                Created = now,
                Updated = now,
                Precipitation = new decimal(1.25),
                TracePrecipitation = false,
                Snow = 0,
                TraceSnow = false
            },
            new()
            {
                Id = Guid.NewGuid(),
                Date = DateOnly.FromDateTime(now.Date).AddDays(-13),
                Created = now,
                Updated = now,
                Precipitation = 0,
                TracePrecipitation = false,
                Snow = 0,
                TraceSnow = false
            },
            new()
            {
                Id = Guid.NewGuid(),
                Date = DateOnly.FromDateTime(now.Date).AddDays(-14),
                Created = now,
                Updated = now,
                Precipitation = new decimal(0.05),
                TracePrecipitation = false,
                Snow = 1,
                TraceSnow = false
            },
            new()
            {
                Id = Guid.NewGuid(),
                Date = DateOnly.FromDateTime(now.Date).AddDays(-15),
                Created = now,
                Updated = now,
                Precipitation = 0,
                TracePrecipitation = true,
                Snow = 0,
                TraceSnow = true
            },
            new()
            {
                Id = Guid.NewGuid(),
                Date = DateOnly.FromDateTime(now.Date).AddDays(-16),
                Created = now,
                Updated = now,
                Precipitation = new decimal(0.05),
                TracePrecipitation = false,
                Snow = 0,
                TraceSnow = false
            },
            new()
            {
                Id = Guid.NewGuid(),
                Date = DateOnly.FromDateTime(now.Date).AddDays(-17),
                Created = now,
                Updated = now,
                Precipitation = new decimal(1.25),
                TracePrecipitation = false,
                Snow = 0,
                TraceSnow = false
            },
            new()
            {
                Id = Guid.NewGuid(),
                Date = DateOnly.FromDateTime(now.Date).AddDays(-18),
                Created = now,
                Updated = now,
                Precipitation = 0,
                TracePrecipitation = false,
                Snow = 0,
                TraceSnow = false
            },
            new()
            {
                Id = Guid.NewGuid(),
                Date = DateOnly.FromDateTime(now.Date).AddDays(-19),
                Created = now,
                Updated = now,
                Precipitation = new decimal(0.05),
                TracePrecipitation = false,
                Snow = 1,
                TraceSnow = false
            },
            new()
            {
                Id = Guid.NewGuid(),
                Date = DateOnly.FromDateTime(now.Date).AddDays(-20),
                Created = now,
                Updated = now,
                Precipitation = 0,
                TracePrecipitation = true,
                Snow = 0,
                TraceSnow = true
            },
            new()
            {
                Id = Guid.NewGuid(),
                Date = DateOnly.FromDateTime(now.Date).AddDays(-21),
                Created = now,
                Updated = now,
                Precipitation = new decimal(0.05),
                TracePrecipitation = false,
                Snow = 0,
                TraceSnow = false
            },
            new()
            {
                Id = Guid.NewGuid(),
                Date = DateOnly.FromDateTime(now.Date).AddDays(-22),
                Created = now,
                Updated = now,
                Precipitation = new decimal(1.25),
                TracePrecipitation = false,
                Snow = 0,
                TraceSnow = false
            },
            new()
            {
                Id = Guid.NewGuid(),
                Date = DateOnly.FromDateTime(now.Date).AddDays(-23),
                Created = now,
                Updated = now,
                Precipitation = 0,
                TracePrecipitation = false,
                Snow = 0,
                TraceSnow = false
            },
            new()
            {
                Id = Guid.NewGuid(),
                Date = DateOnly.FromDateTime(now.Date).AddDays(-24),
                Created = now,
                Updated = now,
                Precipitation = new decimal(0.05),
                TracePrecipitation = false,
                Snow = 1,
                TraceSnow = false
            },
            new()
            {
                Id = Guid.NewGuid(),
                Date = DateOnly.FromDateTime(now.Date).AddDays(-25),
                Created = now,
                Updated = now,
                Precipitation = 0,
                TracePrecipitation = true,
                Snow = 0,
                TraceSnow = true
            },
            new()
            {
                Id = Guid.NewGuid(),
                Date = DateOnly.FromDateTime(now.Date).AddDays(-26),
                Created = now,
                Updated = now,
                Precipitation = new decimal(0.05),
                TracePrecipitation = false,
                Snow = 0,
                TraceSnow = false
            },
            new()
            {
                Id = Guid.NewGuid(),
                Date = DateOnly.FromDateTime(now.Date).AddDays(-27),
                Created = now,
                Updated = now,
                Precipitation = new decimal(1.25),
                TracePrecipitation = false,
                Snow = 0,
                TraceSnow = false
            },
            new()
            {
                Id = Guid.NewGuid(),
                Date = DateOnly.FromDateTime(now.Date).AddDays(-28),
                Created = now,
                Updated = now,
                Precipitation = 0,
                TracePrecipitation = false,
                Snow = 0,
                TraceSnow = false
            },
            new()
            {
                Id = Guid.NewGuid(),
                Date = DateOnly.FromDateTime(now.Date).AddDays(-29),
                Created = now,
                Updated = now,
                Precipitation = new decimal(0.05),
                TracePrecipitation = false,
                Snow = 1,
                TraceSnow = false
            },
            new()
            {
                Id = Guid.NewGuid(),
                Date = DateOnly.FromDateTime(now.Date).AddDays(-30),
                Created = now,
                Updated = now,
                Precipitation = 0,
                TracePrecipitation = true,
                Snow = 0,
                TraceSnow = true
            }
        };

        context.LocalWeatherObservations.AddRange(localWeatherObservations);
        context.SaveChanges();
    }
}

using HomeApi.Database.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeApi.Database;

public class ApiDbContext(DbContextOptions<ApiDbContext> options) : DbContext(options)
{
    public DbSet<LocalWeatherObservation> LocalWeatherObservations { get; set; }
}

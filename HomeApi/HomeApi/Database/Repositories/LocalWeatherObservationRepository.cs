using HomeApi.Database.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeApi.Database.Repositories;

public class LocalWeatherObservationRepository(ApiDbContext context) : ILocalWeatherObservationRepository
{
    public async Task AddLocalWeatherObservationAsync(LocalWeatherObservation observation)
    {
        await context.LocalWeatherObservations.AddAsync(observation);
        await context.SaveChangesAsync();
    }

    public async Task<IEnumerable<LocalWeatherObservation>> GetLocalWeatherObservationsAsync()
    {
        return await context.LocalWeatherObservations.OrderByDescending(obs => obs.Date).ToListAsync();
    }

    public async Task<LocalWeatherObservation?> GetLocalWeatherObservationByIdAsync(Guid id)
    {
        return await context.LocalWeatherObservations.FirstOrDefaultAsync(obs => obs.Id == id);
    }
}

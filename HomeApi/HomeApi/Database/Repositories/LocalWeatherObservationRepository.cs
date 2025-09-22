using HomeApi.Database.Entities;
using HomeApi.Models.LocalWeatherObservations;
using Microsoft.EntityFrameworkCore;

namespace HomeApi.Database.Repositories;

public class LocalWeatherObservationRepository(ApiDbContext context) : ILocalWeatherObservationRepository
{
    public async Task AddLocalWeatherObservationAsync(LocalWeatherObservation observation)
    {
        await context.LocalWeatherObservations.AddAsync(observation);
        await context.SaveChangesAsync();
    }

    public async Task UpdateLocalWeatherObservationAsync(LocalWeatherObservation observation)
    {
        context.LocalWeatherObservations.Update((await context.LocalWeatherObservations.FindAsync(observation.Id))!);
        await context.SaveChangesAsync();
    }

    public async Task<IEnumerable<LocalWeatherObservation>> GetLocalWeatherObservationsAsync(int limit, int offset)
    {
        return await context.LocalWeatherObservations.AsNoTracking().OrderByDescending(obs => obs.Date).Skip(limit * (offset - 1)).Take(limit).ToListAsync();
    }

    public async Task<LocalWeatherObservation?> GetLocalWeatherObservationByIdAsync(Guid id)
    {
        return await context.LocalWeatherObservations.AsNoTracking().FirstOrDefaultAsync(obs => obs.Id == id);
    }

    public async Task<IEnumerable<LocalWeatherObservationSummaryDto>> GetLocalWeatherObservationSummariesAsync(bool? yearToDate, int? days)
    {
        var observations = new List<LocalWeatherObservation>();

        if (yearToDate.HasValue)
        {
            var year = DateTimeOffset.UtcNow.Year;
            observations = await context.LocalWeatherObservations
                .AsNoTracking()
                .Where(obs => obs.Date.Year == year)
                .OrderBy(obs => obs.Date)
                .ToListAsync();
        }
        else if (days.HasValue)
        {
            var minDate = DateOnly.FromDateTime(DateTimeOffset.UtcNow.AddDays(-days.Value).Date);
            observations = await context.LocalWeatherObservations
                .AsNoTracking()
                .Where(obs => obs.Date >= minDate)
                .OrderBy(obs => obs.Date)
                .ToListAsync();
        }

        decimal precipSum = 0;
        decimal snowSum = 0;
        var cumulativeList = new List<LocalWeatherObservationSummaryDto>();

        foreach (var obs in observations)
        {
            precipSum += obs.Precipitation;
            snowSum += obs.Snow;
            cumulativeList.Add(new  LocalWeatherObservationSummaryDto
            {
                Id = obs.Id.ToString(),
                Date = obs.Date.ToString("yyyy-MM-dd"),
                Precipitation = obs.Precipitation,
                CumulativePrecipitation = precipSum,
                Snow = obs.Snow,
                CumulativeSnow = snowSum
            });
        }

        return cumulativeList;
    }
}

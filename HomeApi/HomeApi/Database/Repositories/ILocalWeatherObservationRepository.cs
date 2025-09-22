using HomeApi.Database.Entities;
using HomeApi.Models.LocalWeatherObservations;

namespace HomeApi.Database.Repositories;

public interface ILocalWeatherObservationRepository
{
    Task AddLocalWeatherObservationAsync(LocalWeatherObservation observation);
    Task UpdateLocalWeatherObservationAsync(LocalWeatherObservation observation);
    Task<IEnumerable<LocalWeatherObservation>> GetLocalWeatherObservationsAsync(int limit, int offset);
    Task<LocalWeatherObservation?> GetLocalWeatherObservationByIdAsync(Guid id);
    Task<IEnumerable<LocalWeatherObservationSummaryDto>> GetLocalWeatherObservationSummariesAsync(bool? yearToDate, int? days);
}

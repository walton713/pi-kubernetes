using HomeApi.Database.Entities;

namespace HomeApi.Database.Repositories;

public interface ILocalWeatherObservationRepository
{
    Task AddLocalWeatherObservationAsync(LocalWeatherObservation observation);
    Task<IEnumerable<LocalWeatherObservation>> GetLocalWeatherObservationsAsync();
    Task<LocalWeatherObservation?> GetLocalWeatherObservationByIdAsync(Guid id);
}

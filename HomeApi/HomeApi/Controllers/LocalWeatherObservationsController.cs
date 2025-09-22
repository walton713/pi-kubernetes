using AutoMapper;
using HomeApi.Database.Entities;
using HomeApi.Database.Repositories;
using HomeApi.Models.LocalWeatherObservations;
using Microsoft.AspNetCore.Mvc;

namespace HomeApi.Controllers;

[ApiController]
[Route("localweatherobservations")]
public class LocalWeatherObservationsController(ILocalWeatherObservationRepository repository, IMapper mapper)  : ControllerBase
{
    [HttpPost]
    [Produces("application/json")]
    public async Task<IActionResult> AddEditLocalWeatherObservation(AddEditLocalWeatherObservationDto observation)
    {
        var observationEntity = mapper.Map<LocalWeatherObservation>(observation);
        if (observation.Id.HasValue)
        {
            if (await repository.GetLocalWeatherObservationByIdAsync(observation.Id.Value) is null)
            {
                return NotFound();
            }

            await repository.UpdateLocalWeatherObservationAsync(observationEntity);
            return NoContent();
        }
        await  repository.AddLocalWeatherObservationAsync(observationEntity);

        return CreatedAtRoute("GetLocalWeatherObservationById", new { id = observationEntity.Id }, mapper.Map<LocalWeatherObservationDto>(observationEntity));
    }

    [HttpGet]
    [Produces("application/json")]
    public async Task<IActionResult> GetLocalWeatherObservationsAsync(int limit = 10, int offset = 1)
    {
        var observations = await repository.GetLocalWeatherObservationsAsync(limit, offset);

        return Ok(mapper.Map<IEnumerable<LocalWeatherObservationDto>>(observations));
    }

    [HttpGet("{id:guid}", Name = "GetLocalWeatherObservationById")]
    [Produces("application/json")]
    public async Task<IActionResult> GetLocalWeatherObservationByIdAsync(Guid id)
    {
        var observation = await repository.GetLocalWeatherObservationByIdAsync(id);

        if (observation == null) return NotFound();

        return Ok(mapper.Map<LocalWeatherObservationDto>(observation));
    }

    [HttpGet("summaries")]
    [Produces("application/json")]
    public async Task<IActionResult> GetLocalWeatherObservationSummariesAsync(bool? yearToDate, int? days)
    {
        if (!(yearToDate.HasValue || days.HasValue))
        {
            return StatusCode(StatusCodes.Status406NotAcceptable);
        }

        return Ok(await repository.GetLocalWeatherObservationSummariesAsync(yearToDate, days));
    }
}

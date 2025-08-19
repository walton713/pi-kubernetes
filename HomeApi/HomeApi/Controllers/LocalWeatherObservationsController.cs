using AutoMapper;
using HomeApi.Database.Entities;
using HomeApi.Database.Repositories;
using HomeApi.Models.LocalWeatherObservations;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Net.Http.Headers;

namespace HomeApi.Controllers;

[ApiController]
[Route("localweatherobservations")]
public class LocalWeatherObservationsController(ILocalWeatherObservationRepository repository, IMapper mapper)  : ControllerBase
{
    [HttpPost]
    [Produces("application/json", "application/vnd.friendly+json")]
    public async Task<IActionResult> AddLocalWeatherObservation(AddLocalWeatherObservationDto observation, [FromHeader(Name = "Accept")] string? mediaType = "application/json")
    {
        MediaTypeHeaderValue.TryParse(mediaType, out var parsedMediaType);
        var observationEntity = mapper.Map<LocalWeatherObservation>(observation);
        await  repository.AddLocalWeatherObservationAsync(observationEntity);

        return parsedMediaType!.SubTypeWithoutSuffix.EndsWith("friendly", StringComparison.InvariantCultureIgnoreCase)
            ? CreatedAtRoute("GetLocalWeatherObservationById", new { id = observationEntity.Id }, mapper.Map<LocalWeatherObservationsFriendlyDto>(observationEntity))
            : CreatedAtRoute("GetLocalWeatherObservationById", new { id = observationEntity.Id }, mapper.Map<LocalWeatherObservationDto>(observationEntity));
    }

    [HttpGet]
    [Produces("application/json", "application/vnd.friendly+json")]
    public async Task<IActionResult> GetLocalWeatherObservationsAsync([FromHeader(Name = "Accept")] string? mediaType = "application/json")
    {
        MediaTypeHeaderValue.TryParse(mediaType, out var parsedMediaType);
        var observations = await repository.GetLocalWeatherObservationsAsync();

        return parsedMediaType!.SubTypeWithoutSuffix.EndsWith("friendly", StringComparison.InvariantCultureIgnoreCase)
            ? Ok(mapper.Map<IEnumerable<LocalWeatherObservationsFriendlyDto>>(observations))
            : Ok(mapper.Map<IEnumerable<LocalWeatherObservationDto>>(observations));
    }

    [HttpGet("{id:guid}", Name = "GetLocalWeatherObservationById")]
    [Produces("application/json", "application/vnd.friendly+json")]
    public async Task<IActionResult> GetLocalWeatherObservationByIdAsync(Guid id, [FromHeader(Name = "Accept")] string? mediaType = "application/json")
    {
        MediaTypeHeaderValue.TryParse(mediaType, out var parsedMediaType);
        var observation = await repository.GetLocalWeatherObservationByIdAsync(id);

        if (observation == null) return NotFound();

        return parsedMediaType!.SubTypeWithoutSuffix.EndsWith("friendly", StringComparison.InvariantCultureIgnoreCase)
            ? Ok(mapper.Map<LocalWeatherObservationsFriendlyDto>(observation))
            : Ok(mapper.Map<LocalWeatherObservationDto>(observation));
    }
}

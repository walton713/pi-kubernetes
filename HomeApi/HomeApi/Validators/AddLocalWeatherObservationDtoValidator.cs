using FluentValidation;
using HomeApi.Models.LocalWeatherObservations;

namespace HomeApi.Validators;

public class AddLocalWeatherObservationDtoValidator : AbstractValidator<AddEditLocalWeatherObservationDto>
{
    public AddLocalWeatherObservationDtoValidator()
    {
        RuleLevelCascadeMode = CascadeMode.Stop;

        RuleFor(obs => obs.Precipitation)
            .MustBePositive("precipitation");

        RuleFor(obs => obs.Snow)
            .MustBePositive("snow")
            .MustBeZeroIf(obs => obs.Precipitation == 0 && !obs.TracePrecipitation, "snow", "no precipitation");

        RuleFor(obs => obs.TracePrecipitation)
            .MustBeFalseIf(obs => obs.Precipitation != 0, "tracePrecipitation", "precipitation is non-zero");

        RuleFor(obs => obs.TraceSnow)
            .MustBeFalseIf(obs => obs.Snow != 0, "traceSnow", "snow is non-zero")
            .MustBeFalseIf(obs => obs.Precipitation == 0 && !obs.TracePrecipitation, "traceSnow", "no precipitation");
    }
}

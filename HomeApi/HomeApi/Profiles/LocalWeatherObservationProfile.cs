using AutoMapper;
using HomeApi.Database.Entities;
using HomeApi.Models.LocalWeatherObservations;

namespace HomeApi.Profiles;

public class LocalWeatherObservationProfile : Profile
{
    public LocalWeatherObservationProfile()
    {
        CreateMap<AddLocalWeatherObservationDto, LocalWeatherObservation>()
            .ForMember(d => d.Id, o => o.MapFrom(_ => Guid.NewGuid()))
            .ForMember(d => d.Created, o => o.MapFrom(_ => DateTimeOffset.UtcNow.UtcDateTime))
            .ForMember(d => d.Updated, o => o.MapFrom(_ => DateTimeOffset.UtcNow.UtcDateTime));

        CreateMap<LocalWeatherObservation, LocalWeatherObservationDto>()
            .ForMember(d => d.Id, o => o.MapFrom(s => s.Id.ToString()))
            .ForMember(d => d.Date, o => o.MapFrom(s => s.Date.ToString("O")))
            .ForMember(d => d.Created, o => o.MapFrom(s => s.Created.ToString("u")))
            .ForMember(d => d.Updated, o => o.MapFrom(s => s.Updated.ToString("u")));

        CreateMap<LocalWeatherObservation, LocalWeatherObservationsFriendlyDto>()
            .ForMember(d => d.Id, o => o.MapFrom(s => s.Id.ToString()))
            .ForMember(d => d.Date, o => o.MapFrom(s => s.Date.ToString("O")))
            .ForMember(d => d.Precipitation, o => o.MapFrom<PrecipitationToStringResolver>())
            .ForMember(d => d.Snow, o => o.MapFrom<SnowToStringResolver>());
    }

    private sealed class PrecipitationToStringResolver : IValueResolver<LocalWeatherObservation, LocalWeatherObservationsFriendlyDto, string>
    {
        public string Resolve(LocalWeatherObservation source, LocalWeatherObservationsFriendlyDto destination,
            string destMember, ResolutionContext context) =>
            source.TracePrecipitation ? "T" : $"{source.Precipitation:0.##}\"";
    }

    private sealed class SnowToStringResolver : IValueResolver<LocalWeatherObservation, LocalWeatherObservationsFriendlyDto, string>
    {
        public string Resolve(LocalWeatherObservation source, LocalWeatherObservationsFriendlyDto destination,
            string destMember, ResolutionContext context) =>
            source.TraceSnow ? "T" : $"{source.Snow:0.##}\"";
    }
}

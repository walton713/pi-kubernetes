namespace HomeApi.Models.LocalWeatherObservations;

public class LocalWeatherObservationDto
{
    public string Id { get; set; }

    public string Date { get; set; }

    public string Created { get; set; }

    public string Updated { get; set; }

    public decimal Precipitation { get; set; }

    public decimal Snow { get; set; }

    public bool TracePrecipitation { get; set; }

    public bool TraceSnow { get; set; }

    public string PrecipitationString { get; set; }

    public string SnowString { get; set; }
}

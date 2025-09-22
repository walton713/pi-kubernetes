namespace HomeApi.Models.LocalWeatherObservations;

public class AddEditLocalWeatherObservationDto
{
    public Guid? Id { get; set; }

    public DateOnly Date { get; set; }

    public decimal Precipitation { get; set; }

    public decimal Snow { get; set; }

    public bool TracePrecipitation { get; set; }

    public bool TraceSnow { get; set; }
}

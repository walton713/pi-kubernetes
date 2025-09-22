namespace HomeApi.Models.LocalWeatherObservations;

public class LocalWeatherObservationSummaryDto
{
    public string Id { get; set; }

    public string Date { get; set; }

    public decimal Precipitation { get; set; }

    public decimal CumulativePrecipitation { get; set; }

    public decimal Snow { get; set; }

    public decimal CumulativeSnow { get; set; }
}

using System.ComponentModel.DataAnnotations.Schema;

namespace HomeApi.Database.Entities;

[Table("LocalWeatherObservations")]
public class LocalWeatherObservation : BaseEntity
{
    public DateOnly Date { get; set; }

    public DateTimeOffset Created { get; set; }

    public DateTimeOffset Updated { get; set; }

    public decimal Precipitation { get; set; }

    public decimal Snow { get; set; }

    public bool TracePrecipitation { get; set; }

    public bool TraceSnow { get; set; }
}

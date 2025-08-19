using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HomeApi.Database.Entities;

public class BaseEntity
{
    [Key]
#if !DEBUG
    [Column(TypeName = "BINARY(16)")]
#endif
    public Guid Id { get; set; }
}

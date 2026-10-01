namespace OVOCALIDAD.Application.DTOs.Mantenimientos;

public class IngredienteMantenimientoDto
{
    public int IngredienteId { get; set; }
    public string IngredienteDescripcion { get; set; } = string.Empty;
    public string? UnidadDeMedida { get; set; }
    public bool Estado { get; set; }
    public string AudUsuarioCreacion { get; set; } = string.Empty;
    public DateTime AudFechaCreacion { get; set; }
    public string? AudUsuarioModificacion { get; set; }
    public DateTime? AudFechaActualizacion { get; set; }
    public bool TieneUso { get; set; }
}
public class IngredienteMantenimientoFiltro { public string? Busqueda { get; set; } public bool? Estado { get; set; } }
public class GuardarIngredienteRequest
{
    public int? IngredienteId { get; set; }
    public string IngredienteDescripcion { get; set; } = string.Empty;
    public string Usuario { get; set; } = string.Empty;
}
public class GuardarIngredienteResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? IngredienteId { get; set; }
}
public class CambiarEstadoIngredienteRequest
{
    public bool Estado { get; set; }
    public string Usuario { get; set; } = string.Empty;
}
public class CambiarEstadoIngredienteResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? IngredienteId { get; set; }
    public bool? Estado { get; set; }
}

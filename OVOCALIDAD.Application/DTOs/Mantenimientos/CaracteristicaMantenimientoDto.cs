namespace OVOCALIDAD.Application.DTOs.Mantenimientos;

public class CaracteristicaMantenimientoDto
{
    public int CaracteristicaId { get; set; }
    public string CaracteristicaDescripcion { get; set; } = string.Empty;
    public string? CaracteristicaUnidadDeMedida { get; set; }
    public int TipoCaractId { get; set; }
    public string TipoCaractDescripcion { get; set; } = string.Empty;
    public int? MetEnsayoId { get; set; }
    public string? MetEnsayoDescripcion { get; set; }
    public bool Estado { get; set; }
    public string AudUsuarioCreacion { get; set; } = string.Empty;
    public DateTime AudFechaCreacion { get; set; }
    public string? AudUsuarioModificacion { get; set; }
    public DateTime? AudFechaActualizacion { get; set; }
    public bool TieneUso { get; set; }
}

public class CaracteristicaMantenimientoFiltro
{
    public string? Busqueda { get; set; }
    public int? TipoCaractId { get; set; }
    public bool? Estado { get; set; }
}

public class TipoCaracteristicaMantenimientoDto
{
    public int TipoCaractId { get; set; }
    public string TipoCaractDescripcion { get; set; } = string.Empty;
}

public class MetodoEnsayoMantenimientoDto
{
    public int MetEnsayoId { get; set; }
    public string MetEnsayoDescripcion { get; set; } = string.Empty;
}

public class CatalogosCaracteristicaMantenimientoDto
{
    public IReadOnlyList<TipoCaracteristicaMantenimientoDto> TiposCaracteristica { get; set; } = [];
    public IReadOnlyList<MetodoEnsayoMantenimientoDto> MetodosEnsayo { get; set; } = [];
}

public class GuardarCaracteristicaRequest
{
    public int? CaracteristicaId { get; set; }
    public string CaracteristicaDescripcion { get; set; } = string.Empty;
    public string? CaracteristicaUnidadDeMedida { get; set; }
    public int TipoCaractId { get; set; }
    public int? MetEnsayoId { get; set; }
    public string Usuario { get; set; } = string.Empty;
}

public class GuardarCaracteristicaResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? CaracteristicaId { get; set; }
}

public class CambiarEstadoCaracteristicaRequest
{
    public bool Estado { get; set; }
    public string Usuario { get; set; } = string.Empty;
}

public class CambiarEstadoCaracteristicaResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? CaracteristicaId { get; set; }
    public bool? Estado { get; set; }
}

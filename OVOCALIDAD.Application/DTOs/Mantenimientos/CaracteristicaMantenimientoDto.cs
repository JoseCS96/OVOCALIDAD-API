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
    public int MetEnsayoId { get; set; }
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


public class TipoCaracteristicaMantenimientoDetalleDto
{
    public int TipoCaractId { get; set; }
    public string TipoCaractDescripcion { get; set; } = string.Empty;
    public bool Estado { get; set; }
    public string AudUsuarioCreacion { get; set; } = string.Empty;
    public DateTime AudFechaCreacion { get; set; }
    public string? AudUsuarioModificacion { get; set; }
    public DateTime? AudFechaActualizacion { get; set; }
    public bool TieneUso { get; set; }
}

public class TipoCaracteristicaMantenimientoFiltro
{
    public string? Busqueda { get; set; }
    public bool? Estado { get; set; }
}

public class GuardarTipoCaracteristicaRequest
{
    public int? TipoCaractId { get; set; }
    public string TipoCaractDescripcion { get; set; } = string.Empty;
    public string Usuario { get; set; } = string.Empty;
}

public class GuardarTipoCaracteristicaResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? TipoCaractId { get; set; }
}

public class CambiarEstadoTipoCaracteristicaRequest
{
    public bool Estado { get; set; }
    public string Usuario { get; set; } = string.Empty;
}

public class CambiarEstadoTipoCaracteristicaResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? TipoCaractId { get; set; }
    public bool? Estado { get; set; }
}

public class MetodoEnsayoMantenimientoDetalleDto
{
    public int MetEnsayoId { get; set; }
    public string MetEnsayoDescripcion { get; set; } = string.Empty;
    public bool Estado { get; set; }
    public string AudUsuarioCreacion { get; set; } = string.Empty;
    public DateTime AudFechaCreacion { get; set; }
    public string? AudUsuarioModificacion { get; set; }
    public DateTime? AudFechaActualizacion { get; set; }
    public bool TieneUso { get; set; }
}

public class MetodoEnsayoMantenimientoFiltro
{
    public string? Busqueda { get; set; }
    public bool? Estado { get; set; }
}

public class GuardarMetodoEnsayoRequest
{
    public int? MetEnsayoId { get; set; }
    public string MetEnsayoDescripcion { get; set; } = string.Empty;
    public string Usuario { get; set; } = string.Empty;
}

public class GuardarMetodoEnsayoResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? MetEnsayoId { get; set; }
}

public class CambiarEstadoMetodoEnsayoRequest
{
    public bool Estado { get; set; }
    public string Usuario { get; set; } = string.Empty;
}

public class CambiarEstadoMetodoEnsayoResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? MetEnsayoId { get; set; }
    public bool? Estado { get; set; }
}


public class ContenidoRotuladoMantenimientoDto
{
    public int ContRotuladoId { get; set; }
    public string? ContRotuladoDescripcion { get; set; }
    public bool Estado { get; set; }
    public string AudUsuarioCreacion { get; set; } = string.Empty;
    public DateTime AudFechaCreacion { get; set; }
    public string? AudUsuarioModificacion { get; set; }
    public DateTime? AudFechaActualizacion { get; set; }
    public bool TieneUso { get; set; }
}

public class ContenidoRotuladoMantenimientoFiltro
{
    public string? Busqueda { get; set; }
    public bool? Estado { get; set; }
}

public class GuardarContenidoRotuladoRequest
{
    public int? ContRotuladoId { get; set; }
    public string ContRotuladoDescripcion { get; set; } = string.Empty;
    public string Usuario { get; set; } = string.Empty;
}

public class GuardarContenidoRotuladoResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? ContRotuladoId { get; set; }
}

public class CambiarEstadoContenidoRotuladoRequest
{
    public bool Estado { get; set; }
    public string Usuario { get; set; } = string.Empty;
}

public class CambiarEstadoContenidoRotuladoResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? ContRotuladoId { get; set; }
    public bool? Estado { get; set; }
}

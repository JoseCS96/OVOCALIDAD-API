namespace OVOCALIDAD.Application.DTOs.Mantenimientos;

public class CargoMantenimientoFiltro
{
    public string? Busqueda { get; set; }
    public bool? Estado { get; set; }
}

public class CargoMantenimientoDto
{
    public int CargoId { get; set; }
    public string CargoDescripcion { get; set; } = string.Empty;
    public bool Estado { get; set; }
    public string? AudUsuarioCreacion { get; set; }
    public DateTime AudFechaCreacion { get; set; }
    public string? AudUsuarioModificacion { get; set; }
    public DateTime? AudFechaActualizacion { get; set; }
    public bool TieneUso { get; set; }
    public int CantidadResponsables { get; set; }
}

public class CargoActivoDto
{
    public int CargoId { get; set; }
    public string CargoDescripcion { get; set; } = string.Empty;
}

public class GuardarCargoRequest
{
    public int? CargoId { get; set; }
    public string CargoDescripcion { get; set; } = string.Empty;
    public string Usuario { get; set; } = string.Empty;
}

public class GuardarCargoResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? CargoId { get; set; }
}

public class CambiarEstadoCargoRequest
{
    public bool Estado { get; set; }
    public string Usuario { get; set; } = string.Empty;
}

public class CambiarEstadoCargoResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? CargoId { get; set; }
    public bool? Estado { get; set; }
}

public class ResponsableMantenimientoFiltro
{
    public string? Busqueda { get; set; }
    public bool? Estado { get; set; }
}

public class ResponsableMantenimientoDto
{
    public string UsuarioDni { get; set; } = string.Empty;
    public string UsuarioNombresApellidos { get; set; } = string.Empty;
    public bool Estado { get; set; }
    public DateTime? UsuarioInicioVigencia { get; set; }
    public DateTime? UsuarioFinVigencia { get; set; }
    public int TipoUsuarioId { get; set; }
    public int? UsuarioCargoHistorialId { get; set; }
    public int? CargoId { get; set; }
    public string? CargoDescripcion { get; set; }
    public DateTime? CargoFechaInicio { get; set; }
    public bool TieneCargoActual { get; set; }
    public bool TieneUso { get; set; }
    public string? AudUsuarioCreacion { get; set; }
    public DateTime AudFechaCreacion { get; set; }
    public string? AudUsuarioModificacion { get; set; }
    public DateTime? AudFechaActualizacion { get; set; }
}

public class CrearResponsableRequest
{
    public string UsuarioDni { get; set; } = string.Empty;
    public string UsuarioNombresApellidos { get; set; } = string.Empty;
    public int CargoId { get; set; }
    public DateTime? FechaInicioCargo { get; set; }
    public string Usuario { get; set; } = string.Empty;
}

public class CrearResponsableResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public string? UsuarioDni { get; set; }
    public int? UsuarioCargoHistorialId { get; set; }
    public int? CargoId { get; set; }
}

public class EditarResponsableRequest
{
    public string UsuarioNombresApellidos { get; set; } = string.Empty;
    public string Usuario { get; set; } = string.Empty;
}

public class OperacionResponsableResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public string? UsuarioDni { get; set; }
}

public class CambiarCargoResponsableRequest
{
    public int CargoId { get; set; }
    public DateTime? FechaInicioCargo { get; set; }
    public string Usuario { get; set; } = string.Empty;
}

public class CambiarCargoResponsableResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public string? UsuarioDni { get; set; }
    public int? UsuarioCargoHistorialId { get; set; }
    public int? CargoId { get; set; }
}

public class HistorialCargoResponsableDto
{
    public int UsuarioCargoHistorialId { get; set; }
    public string UsuarioDni { get; set; } = string.Empty;
    public string UsuarioNombresApellidos { get; set; } = string.Empty;
    public int CargoId { get; set; }
    public string CargoDescripcion { get; set; } = string.Empty;
    public DateTime? FechaInicio { get; set; }
    public DateTime? FechaFin { get; set; }
    public bool CargoActual { get; set; }
    public bool Estado { get; set; }
    public string? AudUsuarioCreacion { get; set; }
    public DateTime AudFechaCreacion { get; set; }
    public string? AudUsuarioModificacion { get; set; }
    public DateTime? AudFechaActualizacion { get; set; }
}

public class CambiarEstadoResponsableRequest
{
    public bool Estado { get; set; }
    public string Usuario { get; set; } = string.Empty;
}

public class CambiarEstadoResponsableResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public string? UsuarioDni { get; set; }
    public bool? Estado { get; set; }
}


public class GuardarCargoHistoricoResponsableRequest
{
    public int CargoId { get; set; }
    public DateTime? FechaInicio { get; set; }
    public DateTime? FechaFin { get; set; }
    public string Usuario { get; set; } = string.Empty;
}

public class GuardarCargoHistoricoResponsableResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? UsuarioCargoHistorialId { get; set; }
    public string? UsuarioDni { get; set; }
    public int? CargoId { get; set; }
}


public class FirmaResponsableDto
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public string UsuarioDni { get; set; } = string.Empty;
    public string? FirmaMimeType { get; set; }
    public string? FirmaNombreArchivo { get; set; }
    public byte[]? FirmaImagen { get; set; }
    public DateTime? FechaActualizacion { get; set; }
}

public class GuardarFirmaResponsableRequest
{
    public string UsuarioDni { get; set; } = string.Empty;
    public byte[] FirmaImagen { get; set; } = [];
    public string FirmaMimeType { get; set; } = string.Empty;
    public string? FirmaNombreArchivo { get; set; }
    public string Usuario { get; set; } = string.Empty;
}

public class OperacionFirmaResponsableResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public string? UsuarioDni { get; set; }
}


public class VinculoResponsableUsuarioDto
{
    public string UsuarioDni { get; set; } = string.Empty;
    public int? SegUsuarioId { get; set; }
    public string? NombreUsuario { get; set; }
    public string? NombresApellidos { get; set; }
}

public class VincularResponsableUsuarioRequest
{
    public string NombreUsuario { get; set; } = string.Empty;
    public string Usuario { get; set; } = string.Empty;
}

public class VincularResponsableUsuarioResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public string? UsuarioDni { get; set; }
    public int? SegUsuarioId { get; set; }
    public string? NombreUsuario { get; set; }
}

namespace OVOCALIDAD.Application.DTOs.Seguridad;

public class UsuarioAccesoMantenimientoDto
{
    public int SegUsuarioId { get; set; }
    public string NombreUsuario { get; set; } = string.Empty;
    public string NombresApellidos { get; set; } = string.Empty;
    public string? Correo { get; set; }
    public bool Estado { get; set; }
    public DateTime? UltimoAcceso { get; set; }
    public string? PerfilCodigo { get; set; }
    public string? PerfilDescripcion { get; set; }
    public string? UsuarioDniResponsable { get; set; }
    public string? ResponsableNombre { get; set; }
}

public class PerfilAccesoMantenimientoDto
{
    public int PerfilId { get; set; }
    public string PerfilCodigo { get; set; } = string.Empty;
    public string PerfilDescripcion { get; set; } = string.Empty;
}

public class CambiarEstadoUsuarioAccesoResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int SegUsuarioId { get; set; }
    public bool Estado { get; set; }
}


public class CambiarEstadoUsuarioAccesoRequest
{
    public bool Estado { get; set; }
}

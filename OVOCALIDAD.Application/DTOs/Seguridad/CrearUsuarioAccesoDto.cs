namespace OVOCALIDAD.Application.DTOs.Seguridad;

public class CrearUsuarioAccesoRequest
{
    public string NombreUsuario { get; set; } = string.Empty;
    public string NombresApellidos { get; set; } = string.Empty;
    public string? Correo { get; set; }
    public string Password { get; set; } = string.Empty;
    public int PerfilId { get; set; }
}

public class CrearUsuarioAccesoDbRequest
{
    public string NombreUsuario { get; set; } = string.Empty;
    public string NombresApellidos { get; set; } = string.Empty;
    public string? Correo { get; set; }
    public string PasswordHash { get; set; } = string.Empty;
    public int PerfilId { get; set; }
    public string UsuarioAuditoria { get; set; } = string.Empty;
}

public class CrearUsuarioAccesoResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? SegUsuarioId { get; set; }
    public string? NombreUsuario { get; set; }
    public int? PerfilId { get; set; }
}

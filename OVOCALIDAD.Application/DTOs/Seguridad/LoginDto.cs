namespace OVOCALIDAD.Application.DTOs.Seguridad;

public class LoginRequest
{
    public string NombreUsuario { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}

public class LoginResponse
{
    public string Token { get; set; } = string.Empty;
    public DateTime ExpiraEn { get; set; }
    public UsuarioAccesoDto Usuario { get; set; } = new();
}

public class UsuarioAutenticacionDto
{
    public int SegUsuarioId { get; set; }
    public string NombreUsuario { get; set; } = string.Empty;
    public string NombresApellidos { get; set; } = string.Empty;
    public string? Correo { get; set; }
    public string? PasswordHash { get; set; }
}

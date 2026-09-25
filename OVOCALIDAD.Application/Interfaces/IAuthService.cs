using OVOCALIDAD.Application.DTOs.Seguridad;

namespace OVOCALIDAD.Application.Interfaces;

public interface IAuthService
{
    Task<LoginResponse?> LoginAsync(LoginRequest request);
}

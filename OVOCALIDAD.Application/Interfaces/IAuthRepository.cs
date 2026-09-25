using OVOCALIDAD.Application.DTOs.Seguridad;

namespace OVOCALIDAD.Application.Interfaces;

public interface IAuthRepository
{
    Task<UsuarioAutenticacionDto?> ObtenerUsuarioAutenticacionAsync(string nombreUsuario);
    Task ActualizarUltimoAccesoAsync(int segUsuarioId);
}

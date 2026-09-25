using OVOCALIDAD.Application.DTOs.Seguridad;
using OVOCALIDAD.Application.Interfaces;
using OVOCALIDAD.Infrastructure.StoredProcedures;

namespace OVOCALIDAD.Infrastructure.Repositories;

public class AuthRepository : IAuthRepository
{
    private readonly AuthStoredProcedure _storedProcedure;

    public AuthRepository(AuthStoredProcedure storedProcedure)
    {
        _storedProcedure = storedProcedure;
    }

    public Task<UsuarioAutenticacionDto?> ObtenerUsuarioAutenticacionAsync(string nombreUsuario) =>
        _storedProcedure.ObtenerUsuarioAutenticacionAsync(nombreUsuario);

    public Task ActualizarUltimoAccesoAsync(int segUsuarioId) =>
        _storedProcedure.ActualizarUltimoAccesoAsync(segUsuarioId);
}

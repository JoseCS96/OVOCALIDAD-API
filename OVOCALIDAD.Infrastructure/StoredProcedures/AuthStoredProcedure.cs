using Microsoft.Data.SqlClient;
using OVOCALIDAD.Application.DTOs.Seguridad;
using OVOCALIDAD.Infrastructure.Mappers;
using SPNames = OVOCALIDAD.Shared.Constants.StoredProcedures;

namespace OVOCALIDAD.Infrastructure.StoredProcedures;

public class AuthStoredProcedure
{
    private readonly StoredProcedureExecutor _executor;

    public AuthStoredProcedure(StoredProcedureExecutor executor)
    {
        _executor = executor;
    }

    public async Task<UsuarioAutenticacionDto?> ObtenerUsuarioAutenticacionAsync(string nombreUsuario)
    {
        var parametros = new List<SqlParameter> { new("@NombreUsuario", nombreUsuario) };

        using var reader = await _executor.ExecuteReaderAsync(
            SPNames.SP_OBTENER_USUARIO_AUTENTICACION,
            parametros);

        return await reader.ReadAsync()
            ? reader.MapTo<UsuarioAutenticacionDto>()
            : null;
    }

    public async Task ActualizarUltimoAccesoAsync(int segUsuarioId)
    {
        var parametros = new List<SqlParameter> { new("@SegUsuarioId", segUsuarioId) };

        using var reader = await _executor.ExecuteReaderAsync(
            SPNames.SP_ACTUALIZAR_ULTIMO_ACCESO,
            parametros);
    }
}

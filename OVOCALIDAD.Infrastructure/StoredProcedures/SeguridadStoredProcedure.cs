using Microsoft.Data.SqlClient;
using OVOCALIDAD.Application.DTOs.Seguridad;
using OVOCALIDAD.Infrastructure.Mappers;
using SPNames = OVOCALIDAD.Shared.Constants.StoredProcedures;

namespace OVOCALIDAD.Infrastructure.StoredProcedures;

public class SeguridadStoredProcedure
{
    private readonly StoredProcedureExecutor _executor;

    public SeguridadStoredProcedure(StoredProcedureExecutor executor)
    {
        _executor = executor;
    }

    public async Task<AccesosUsuarioDto?> ObtenerAccesosUsuarioAsync(string nombreUsuario)
    {
        var parametros = new List<SqlParameter>
        {
            new("@NombreUsuario", nombreUsuario)
        };

        using var reader = await _executor.ExecuteReaderAsync(
            SPNames.SP_OBTENER_ACCESOS_USUARIO,
            parametros);

        if (!await reader.ReadAsync())
            return null;

        var codigoResultado = reader.GetInt32(reader.GetOrdinal("CodigoResultado"));
        if (codigoResultado != 0)
            return null;

        var usuario = reader.MapTo<UsuarioAccesoDto>();

        var perfiles = new List<PerfilAccesoDto>();
        if (await reader.NextResultAsync())
            while (await reader.ReadAsync())
                perfiles.Add(reader.MapTo<PerfilAccesoDto>());

        var modulos = new List<ModuloAccesoDto>();
        if (await reader.NextResultAsync())
            while (await reader.ReadAsync())
                modulos.Add(reader.MapTo<ModuloAccesoDto>());

        var permisos = new List<string>();
        if (await reader.NextResultAsync())
        {
            var ordinalPermisoCodigo = reader.GetOrdinal("PermisoCodigo");
            while (await reader.ReadAsync())
                permisos.Add(reader.GetString(ordinalPermisoCodigo));
        }

        return new AccesosUsuarioDto
        {
            Usuario = usuario,
            Perfiles = perfiles,
            Modulos = modulos,
            Permisos = permisos
        };
    }
    public async Task<IReadOnlyList<NotificacionDto>> ObtenerNotificacionesAsync(string nombreUsuario)
    {
        var parametros = new List<SqlParameter> { new("@NombreUsuario", nombreUsuario) };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_OBTENER_NOTIFICACIONES_USUARIO, parametros);
        var items = new List<NotificacionDto>();
        while (await reader.ReadAsync()) items.Add(reader.MapTo<NotificacionDto>());
        return items;
    }

    public async Task<OperacionNotificacionDto> MarcarNotificacionLeidaAsync(long notificacionId, string nombreUsuario)
    {
        var parametros = new List<SqlParameter>
        {
            new("@NotificacionId", notificacionId),
            new("@NombreUsuario", nombreUsuario)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_MARCAR_NOTIFICACION_LEIDA, parametros);
        return await reader.ReadAsync() ? reader.MapTo<OperacionNotificacionDto>() : new OperacionNotificacionDto { CodigoResultado = -1, Mensaje = "Sin resultado." };
    }

    public async Task<OperacionNotificacionDto> MarcarNotificacionesModalMostradasAsync(string nombreUsuario)
    {
        var parametros = new List<SqlParameter> { new("@NombreUsuario", nombreUsuario) };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_MARCAR_NOTIFICACIONES_MODAL_MOSTRADAS, parametros);
        return await reader.ReadAsync() ? reader.MapTo<OperacionNotificacionDto>() : new OperacionNotificacionDto { CodigoResultado = -1, Mensaje = "Sin resultado." };
    }
}

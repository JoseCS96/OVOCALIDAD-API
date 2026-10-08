using System.Text.Json;
using Microsoft.Data.SqlClient;
using OVOCALIDAD.Application.DTOs.EspecificacionesTecnicas;
using OVOCALIDAD.Application.DTOs.Firmas;
using OVOCALIDAD.Infrastructure.Mappers;
using SPNames = OVOCALIDAD.Shared.Constants.StoredProcedures;

namespace OVOCALIDAD.Infrastructure.StoredProcedures;

public class FirmaDocumentoStoredProcedure
{
    private readonly StoredProcedureExecutor _executor;

    public FirmaDocumentoStoredProcedure(StoredProcedureExecutor executor)
    {
        _executor = executor;
    }

    public async Task<IReadOnlyList<FirmaDocumentoSolicitudDto>> ListarMisSolicitudesAsync(string nombreUsuario, string? estado)
    {
        var parametros = new List<SqlParameter>
        {
            new("@NombreUsuario", nombreUsuario),
            new("@Estado", (object?)estado ?? DBNull.Value)
        };

        using var reader = await _executor.ExecuteReaderAsync(
            SPNames.SP_LISTAR_MIS_SOLICITUDES_FIRMA,
            parametros);

        var items = new List<FirmaDocumentoSolicitudDto>();
        while (await reader.ReadAsync())
            items.Add(reader.MapTo<FirmaDocumentoSolicitudDto>());

        return items;
    }

    public async Task<FirmaDocumentoSolicitudDto?> ObtenerMiSolicitudAsync(string nombreUsuario, string tipoDocumento, int entidadId)
    {
        var parametros = new List<SqlParameter>
        {
            new("@NombreUsuario", nombreUsuario),
            new("@TipoDocumento", tipoDocumento),
            new("@EntidadId", entidadId)
        };

        using var reader = await _executor.ExecuteReaderAsync(
            SPNames.SP_OBTENER_MI_SOLICITUD_FIRMA_DOCUMENTO,
            parametros);

        return await reader.ReadAsync()
            ? reader.MapTo<FirmaDocumentoSolicitudDto>()
            : null;
    }

    public async Task<OperacionFirmaDocumentoResponse> FirmarAsync(long solicitudId, string nombreUsuario)
    {
        var parametros = new List<SqlParameter>
        {
            new("@DocumentoFirmaSolicitudId", solicitudId),
            new("@NombreUsuario", nombreUsuario)
        };

        using var reader = await _executor.ExecuteReaderAsync(
            SPNames.SP_FIRMAR_DOCUMENTO,
            parametros);

        return await reader.ReadAsync()
            ? reader.MapTo<OperacionFirmaDocumentoResponse>()
            : new OperacionFirmaDocumentoResponse
            {
                CodigoResultado = -1,
                Mensaje = "El procedimiento no devolvió resultado.",
                DocumentoFirmaSolicitudId = solicitudId
            };
    }

    public async Task<FirmaDocumentoAplicadaDto?> ObtenerFirmaAplicadaAsync(string tipoDocumento, int entidadId, string usuarioDni)
    {
        var parametros = new List<SqlParameter>
        {
            new("@TipoDocumento", tipoDocumento),
            new("@EntidadId", entidadId),
            new("@UsuarioDni", usuarioDni)
        };

        using var reader = await _executor.ExecuteReaderAsync(
            SPNames.SP_OBTENER_FIRMA_DOCUMENTO_APLICADA,
            parametros);

        return await reader.ReadAsync()
            ? reader.MapTo<FirmaDocumentoAplicadaDto>()
            : null;
    }
    public async Task<GenerarSolicitudesFirmaResponse> GenerarSolicitudesEtAsync(
        int versionId,
        IReadOnlyList<ResponsableEtDto> responsables,
        string usuario)
    {
        var json = JsonSerializer.Serialize(
            responsables,
            new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase });

        var parametros = new List<SqlParameter>
        {
            new("@VersionId", versionId),
            new("@ResponsablesJson", json),
            new("@Usuario", usuario)
        };

        using var reader = await _executor.ExecuteReaderAsync(
            SPNames.SP_GENERAR_SOLICITUDES_FIRMA_ET,
            parametros);

        return await reader.ReadAsync()
            ? reader.MapTo<GenerarSolicitudesFirmaResponse>()
            : new GenerarSolicitudesFirmaResponse
            {
                CodigoResultado = -1,
                Mensaje = "El procedimiento no devolvió resultado."
            };
    }
}

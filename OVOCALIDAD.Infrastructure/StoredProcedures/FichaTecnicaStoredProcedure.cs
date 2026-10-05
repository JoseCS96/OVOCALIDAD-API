using Microsoft.Data.SqlClient;
using OVOCALIDAD.Application.DTOs.FichasTecnicas;
using OVOCALIDAD.Infrastructure.Mappers;
using SPNames = OVOCALIDAD.Shared.Constants.StoredProcedures;

namespace OVOCALIDAD.Infrastructure.StoredProcedures;

public class FichaTecnicaStoredProcedure
{
    private readonly StoredProcedureExecutor _executor;

    public FichaTecnicaStoredProcedure(StoredProcedureExecutor executor)
    {
        _executor = executor;
    }

    public async Task<IReadOnlyList<FichaTecnicaCaracteristicaDto>> ListarCaracteristicasAsync(int versionId)
    {
        var parametros = new List<SqlParameter> { new("@VersionId", versionId) };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_LISTAR_CARACTERISTICAS_FT, parametros);
        var items = new List<FichaTecnicaCaracteristicaDto>();
        while (await reader.ReadAsync())
            items.Add(reader.MapTo<FichaTecnicaCaracteristicaDto>());
        return items;
    }

    public async Task<GuardarCaracteristicaFtResponse> GuardarCaracteristicaAsync(int versionId, GuardarCaracteristicaFtRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@VersionFtCaracteristicaId", (object?)request.VersionFtCaracteristicaId ?? DBNull.Value),
            new("@VersionId", versionId),
            new("@CaracteristicaId", request.CaracteristicaId),
            new("@TipoCriterioId", request.TipoCriterioId),
            new("@ValorCuantitativoInicial", (object?)request.ValorCuantitativoInicial ?? DBNull.Value),
            new("@ValorCuantitativoFinal", (object?)request.ValorCuantitativoFinal ?? DBNull.Value),
            new("@ValorCuantitativoIgual", (object?)request.ValorCuantitativoIgual ?? DBNull.Value),
            new("@ValorCualitativo", (object?)request.ValorCualitativo ?? DBNull.Value),
            new("@UnidadDeMedida", (object?)request.UnidadDeMedida ?? DBNull.Value),
            new("@ImprimeCertificado", request.ImprimeCertificado),
            new("@ObligatorioCertificado", request.ObligatorioCertificado),
            new("@OrdenCertificado", (object?)request.OrdenCertificado ?? DBNull.Value),
            new("@Usuario", request.Usuario)
        };

        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_GUARDAR_CARACTERISTICA_FT, parametros);
        return await reader.ReadAsync()
            ? reader.MapTo<GuardarCaracteristicaFtResponse>()
            : new GuardarCaracteristicaFtResponse { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado." };
    }

    public async Task<EliminarCaracteristicaFtResponse> EliminarCaracteristicaAsync(int versionFtCaracteristicaId, string usuario)
    {
        var parametros = new List<SqlParameter>
        {
            new("@VersionFtCaracteristicaId", versionFtCaracteristicaId),
            new("@Usuario", usuario)
        };

        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_ELIMINAR_CARACTERISTICA_FT, parametros);
        return await reader.ReadAsync()
            ? reader.MapTo<EliminarCaracteristicaFtResponse>()
            : new EliminarCaracteristicaFtResponse { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado." };
    }

    public async Task<IReadOnlyList<ConfiguracionCertificadoFtDto>> ObtenerConfiguracionCertificadoAsync(int versionId)
    {
        var parametros = new List<SqlParameter> { new("@VersionId", versionId) };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_OBTENER_CONFIGURACION_CERTIFICADO_FT, parametros);
        var items = new List<ConfiguracionCertificadoFtDto>();
        while (await reader.ReadAsync())
            items.Add(reader.MapTo<ConfiguracionCertificadoFtDto>());
        return items;
    }
}

using System.Text.Json;
using Microsoft.Data.SqlClient;
using OVOCALIDAD.Application.DTOs.FichasTecnicas;
using OVOCALIDAD.Infrastructure.Mappers;
using SPNames = OVOCALIDAD.Shared.Constants.StoredProcedures;

namespace OVOCALIDAD.Infrastructure.StoredProcedures;

public class FichaTecnicaStoredProcedure
{
    private readonly StoredProcedureExecutor _executor;
    public FichaTecnicaStoredProcedure(StoredProcedureExecutor executor) => _executor = executor;

    public async Task<IReadOnlyList<SeccionFichaTecnicaDto>> ListarSeccionesAsync(int versionId)
    {
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_LISTAR_SECCIONES_FT, [new("@VersionId", versionId)]);
        var items = new List<SeccionFichaTecnicaDto>();
        while (await reader.ReadAsync()) items.Add(reader.MapTo<SeccionFichaTecnicaDto>());
        return items;
    }

    public Task<OperacionFichaTecnicaResponse> GuardarSeccionAsync(int versionId, int seccionId, GuardarSeccionFichaTecnicaRequest request) =>
        OperacionAsync(SPNames.SP_GUARDAR_CONTENIDO_SECCION_FT,
        [
            new("@VersionId", versionId), new("@VersionFtSeccionId", seccionId), new("@Titulo", request.Titulo),
            new("@Contenido", (object?)request.Contenido ?? DBNull.Value), new("@Visible", request.Visible), new("@Usuario", request.Usuario)
        ]);

    public Task<OperacionFichaTecnicaResponse> AgregarSeccionAsync(int versionId, AgregarSeccionFichaTecnicaRequest request) =>
        OperacionAsync(SPNames.SP_AGREGAR_SECCION_FT,
        [
            new("@VersionId", versionId), new("@Titulo", request.Titulo), new("@TipoContenido", request.TipoContenido),
            new("@Orden", (object?)request.Orden ?? DBNull.Value), new("@Usuario", request.Usuario)
        ]);

    public Task<OperacionFichaTecnicaResponse> QuitarSeccionAsync(int versionId, int seccionId, QuitarSeccionFichaTecnicaRequest request) =>
        OperacionAsync(SPNames.SP_QUITAR_SECCION_FT,
        [new("@VersionId", versionId), new("@VersionFtSeccionId", seccionId), new("@Usuario", request.Usuario)]);

    public Task<OperacionFichaTecnicaResponse> ReordenarSeccionesAsync(int versionId, ReordenarSeccionesFichaTecnicaRequest request) =>
        OperacionAsync(SPNames.SP_REORDENAR_SECCIONES_FT,
        [
            new("@VersionId", versionId),
            new("@SeccionesJson", JsonSerializer.Serialize(request.Secciones, new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase })),
            new("@Usuario", request.Usuario)
        ]);

    public async Task<IReadOnlyList<CaracteristicaFichaTecnicaDto>> ListarCaracteristicasAsync(int versionId)
    {
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_LISTAR_CARACTERISTICAS_FT, [new("@VersionFtId", versionId)]);
        var items = new List<CaracteristicaFichaTecnicaDto>();
        while (await reader.ReadAsync()) items.Add(reader.MapTo<CaracteristicaFichaTecnicaDto>());
        return items;
    }

    public Task<OperacionFichaTecnicaResponse> GuardarCaracteristicaAsync(int versionId, int caracteristicaId, GuardarCaracteristicaFichaTecnicaRequest request) =>
        OperacionAsync(SPNames.SP_GUARDAR_CARACTERISTICA_FT,
        [
            new("@VersionFtId", versionId), new("@VersionFtCaracteristicaId", caracteristicaId), new("@TipoCriterioId", request.TipoCriterioId),
            new("@ValorCuantitativoInicial", (object?)request.ValorCuantitativoInicial ?? DBNull.Value),
            new("@ValorCuantitativoFinal", (object?)request.ValorCuantitativoFinal ?? DBNull.Value),
            new("@ValorCuantitativoIgual", (object?)request.ValorCuantitativoIgual ?? DBNull.Value),
            new("@ValorCualitativo", (object?)request.ValorCualitativo ?? DBNull.Value),
            new("@UnidadDeMedida", (object?)request.UnidadDeMedida ?? DBNull.Value),
            new("@ImprimeCertificado", request.ImprimeCertificado), new("@ObligatorioCertificado", request.ObligatorioCertificado),
            new("@OrdenCertificado", (object?)request.OrdenCertificado ?? DBNull.Value), new("@Usuario", request.Usuario)
        ]);

    private async Task<OperacionFichaTecnicaResponse> OperacionAsync(string sp, List<SqlParameter> parameters)
    {
        using var reader = await _executor.ExecuteReaderAsync(sp, parameters);
        return await reader.ReadAsync() ? reader.MapTo<OperacionFichaTecnicaResponse>() : new() { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado." };
    }
}

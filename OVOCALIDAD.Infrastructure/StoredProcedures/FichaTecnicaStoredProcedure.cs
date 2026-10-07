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

    public async Task<IReadOnlyList<FichaTecnicaGestionDto>> ListarGestionAsync(string? busqueda, int? estVerId)
    {
        var parametros = new List<SqlParameter>
        {
            new("@Busqueda", (object?)busqueda ?? DBNull.Value),
            new("@EstVerId", (object?)estVerId ?? DBNull.Value)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_LISTAR_FICHAS_TECNICAS, parametros);
        var items = new List<FichaTecnicaGestionDto>();
        while (await reader.ReadAsync()) items.Add(reader.MapTo<FichaTecnicaGestionDto>());
        return items;
    }

    public async Task<FichaTecnicaGestionDto?> ObtenerAsync(int versionId)
    {
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_OBTENER_FICHA_TECNICA, new List<SqlParameter> { new("@VersionId", versionId) });
        return await reader.ReadAsync() ? reader.MapTo<FichaTecnicaGestionDto>() : null;
    }

    public async Task<IReadOnlyList<FichaTecnicaCertificadoDto>> ListarParaCertificadoAsync(string? busqueda)
    {
        var parametros = new List<SqlParameter>
        {
            new("@Busqueda", (object?)busqueda ?? DBNull.Value)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_LISTAR_FICHAS_TECNICAS_CERTIFICADO, parametros);
        var items = new List<FichaTecnicaCertificadoDto>();
        while (await reader.ReadAsync())
            items.Add(reader.MapTo<FichaTecnicaCertificadoDto>());
        return items;
    }

    public async Task<CrearFichaTecnicaResponse> CrearAsync(CrearFichaTecnicaRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@DocumentoCodigo", request.DocumentoCodigo),
            new("@DocumentoDescripcionDocumento", request.DocumentoDescripcionDocumento),
            new("@ProductoCodigo", (object?)request.ProductoCodigo ?? DBNull.Value),
            new("@VersionNumero", (object?)request.VersionNumero ?? DBNull.Value),
            new("@VersionInicioVigencia", (object?)request.VersionInicioVigencia ?? DBNull.Value),
            new("@VersionReemplazaAId", (object?)request.VersionReemplazaAId ?? DBNull.Value),
            new("@VersionNroPaginas", (object?)request.VersionNroPaginas ?? DBNull.Value),
            new("@VersionDescripcion", (object?)request.VersionDescripcion ?? DBNull.Value),
            new("@VersionEtOrigenId", (object?)request.VersionEtOrigenId ?? DBNull.Value),
            new("@Usuario", request.Usuario)
        };

        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_CREAR_FICHA_TECNICA, parametros);
        return await reader.ReadAsync()
            ? reader.MapTo<CrearFichaTecnicaResponse>()
            : new CrearFichaTecnicaResponse { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado." };
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
    public async Task<EliminarFichaTecnicaResponse> EliminarBorradorAsync(int versionId, string usuario)
    {
        var parametros = new List<SqlParameter>
        {
            new("@VersionId", versionId),
            new("@Usuario", usuario)
        };

        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_ELIMINAR_FICHA_TECNICA_BORRADOR, parametros);
        return await reader.ReadAsync()
            ? reader.MapTo<EliminarFichaTecnicaResponse>()
            : new EliminarFichaTecnicaResponse { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado.", VersionId = versionId };
    }
    public async Task<IReadOnlyList<SeccionFtDto>> ListarSeccionesAsync(int versionId)
    {
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_LISTAR_SECCIONES_FT, new List<SqlParameter>{ new("@VersionId", versionId) });
        var items = new List<SeccionFtDto>();
        while (await reader.ReadAsync()) items.Add(reader.MapTo<SeccionFtDto>());
        return items;
    }

    public async Task<SeccionFtOperacionResponse> GuardarContenidoSeccionAsync(int versionId, int versSeccId, GuardarContenidoSeccionFtRequest request)
    {
        var p = new List<SqlParameter>{ new("@VersionId",versionId), new("@VersSeccId",versSeccId), new("@Contenido",(object?)request.Contenido??DBNull.Value), new("@Usuario",request.Usuario)};
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_GUARDAR_CONTENIDO_SECCION_FT,p);
        return await reader.ReadAsync()?reader.MapTo<SeccionFtOperacionResponse>():new SeccionFtOperacionResponse{CodigoResultado=-1,Mensaje="El procedimiento no devolvió resultado."};
    }

    public async Task<SeccionFtOperacionResponse> AgregarSeccionAsync(int versionId, AgregarSeccionFtRequest request)
    {
        var p = new List<SqlParameter>{ new("@VersionId",versionId), new("@SeccionId",request.SeccionId), new("@Orden",(object?)request.Orden??DBNull.Value), new("@Usuario",request.Usuario)};
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_AGREGAR_SECCION_FT,p);
        return await reader.ReadAsync()?reader.MapTo<SeccionFtOperacionResponse>():new SeccionFtOperacionResponse{CodigoResultado=-1,Mensaje="El procedimiento no devolvió resultado."};
    }

    public async Task<SeccionFtOperacionResponse> QuitarSeccionAsync(int versionId, int versSeccId, string usuario)
    {
        var p = new List<SqlParameter>{ new("@VersionId",versionId), new("@VersSeccId",versSeccId), new("@Usuario",usuario)};
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_QUITAR_SECCION_FT,p);
        return await reader.ReadAsync()?reader.MapTo<SeccionFtOperacionResponse>():new SeccionFtOperacionResponse{CodigoResultado=-1,Mensaje="El procedimiento no devolvió resultado."};
    }

    public async Task<SeccionFtOperacionResponse> ReordenarSeccionesAsync(int versionId, ReordenarSeccionesFtRequest request)
    {
        var json = System.Text.Json.JsonSerializer.Serialize(request.Secciones);
        var p = new List<SqlParameter>{ new("@VersionId",versionId), new("@SeccionesJson",json), new("@Usuario",request.Usuario)};
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_REORDENAR_SECCIONES_FT,p);
        return await reader.ReadAsync()?reader.MapTo<SeccionFtOperacionResponse>():new SeccionFtOperacionResponse{CodigoResultado=-1,Mensaje="El procedimiento no devolvió resultado."};
    }
}

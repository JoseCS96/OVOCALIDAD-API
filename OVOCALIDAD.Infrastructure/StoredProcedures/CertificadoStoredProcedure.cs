using System.Text.Json;
using Microsoft.Data.SqlClient;
using OVOCALIDAD.Application.DTOs.Certificados;
using OVOCALIDAD.Infrastructure.Mappers;
using SPNames = OVOCALIDAD.Shared.Constants.StoredProcedures;

namespace OVOCALIDAD.Infrastructure.StoredProcedures;

public class CertificadoStoredProcedure
{
    private readonly StoredProcedureExecutor _executor;
    public CertificadoStoredProcedure(StoredProcedureExecutor executor) => _executor = executor;

    public async Task<PlantillaCertificadoOperacionResponse> CrearPlantillaAsync(CrearPlantillaCertificadoRequest request)
    {
        var p = new List<SqlParameter>
        {
            new("@VersionFtId", request.VersionFtId),
            new("@Nombre", request.Nombre),
            new("@Descripcion", (object?)request.Descripcion ?? DBNull.Value),
            new("@Usuario", request.Usuario)
        };
        using var r = await _executor.ExecuteReaderAsync(SPNames.SP_CREAR_PLANTILLA_CERTIFICADO, p);
        return await r.ReadAsync() ? r.MapTo<PlantillaCertificadoOperacionResponse>()
            : new() { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado." };
    }

    public async Task<IReadOnlyList<PlantillaCertificadoListaDto>> ListarPlantillasAsync(int? versionFtId, string? productoCodigo)
    {
        var p = new List<SqlParameter>
        {
            new("@VersionFtId", (object?)versionFtId ?? DBNull.Value),
            new("@ProductoCodigo", (object?)productoCodigo ?? DBNull.Value)
        };
        using var r = await _executor.ExecuteReaderAsync(SPNames.SP_LISTAR_PLANTILLAS_CERTIFICADO, p);
        var items = new List<PlantillaCertificadoListaDto>();
        while (await r.ReadAsync()) items.Add(r.MapTo<PlantillaCertificadoListaDto>());
        return items;
    }

    public async Task<PlantillaCertificadoDto?> ObtenerPlantillaAsync(int id)
    {
        var p = new List<SqlParameter> { new("@CertificadoPlantillaId", id) };
        using var r = await _executor.ExecuteReaderAsync(SPNames.SP_OBTENER_PLANTILLA_CERTIFICADO, p);
        if (!await r.ReadAsync()) return null;
        var dto = r.MapTo<PlantillaCertificadoDto>();
        if (await r.NextResultAsync())
            while (await r.ReadAsync()) dto.Secciones.Add(r.MapTo<PlantillaCertificadoSeccionDto>());
        if (await r.NextResultAsync())
            while (await r.ReadAsync()) dto.Resultados.Add(r.MapTo<PlantillaCertificadoResultadoDto>());
        if (await r.NextResultAsync())
            while (await r.ReadAsync()) dto.Caracteristicas.Add(r.MapTo<PlantillaCertificadoCaracteristicaDto>());
        return dto;
    }

    public async Task<PlantillaCertificadoOperacionResponse> GuardarDisenoAsync(int id, GuardarDisenoPlantillaCertificadoRequest request)
    {
        var json = JsonSerializer.Serialize(request.Secciones, new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase });
        var p = new List<SqlParameter>
        {
            new("@CertificadoPlantillaId", id),
            new("@SeccionesJson", json),
            new("@Usuario", request.Usuario)
        };
        using var r = await _executor.ExecuteReaderAsync(SPNames.SP_GUARDAR_DISENO_PLANTILLA_CERTIFICADO, p);
        return await r.ReadAsync() ? r.MapTo<PlantillaCertificadoOperacionResponse>()
            : new() { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado." };
    }

    public async Task<PlantillaCertificadoOperacionResponse> EliminarPlantillaAsync(int id, string usuario)
    {
        var p = new List<SqlParameter> { new("@CertificadoPlantillaId", id), new("@Usuario", usuario) };
        using var r = await _executor.ExecuteReaderAsync(SPNames.SP_ELIMINAR_PLANTILLA_CERTIFICADO, p);
        return await r.ReadAsync() ? r.MapTo<PlantillaCertificadoOperacionResponse>()
            : new() { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado." };
    }
    public async Task<CertificadoEmpresaDto?> ObtenerEmpresaAsync()
    {
        using var r = await _executor.ExecuteReaderAsync(
            SPNames.SP_OBTENER_EMPRESA_CERTIFICADO,
            new List<SqlParameter>());
        return await r.ReadAsync() ? r.MapTo<CertificadoEmpresaDto>() : null;
    }

    public async Task<GuardarCertificadoEmpresaResponse> GuardarEmpresaAsync(GuardarCertificadoEmpresaRequest request)
    {
        var p = new List<SqlParameter>
        {
            new("@RazonSocial", request.RazonSocial),
            new("@NombreComercial", (object?)request.NombreComercial ?? DBNull.Value),
            new("@Direccion", (object?)request.Direccion ?? DBNull.Value),
            new("@Telefono", (object?)request.Telefono ?? DBNull.Value),
            new("@Fax", (object?)request.Fax ?? DBNull.Value),
            new("@Correo", (object?)request.Correo ?? DBNull.Value),
            new("@SitioWeb", (object?)request.SitioWeb ?? DBNull.Value),
            new("@Ruc", (object?)request.Ruc ?? DBNull.Value),
            new("@Usuario", request.Usuario)
        };
        using var r = await _executor.ExecuteReaderAsync(SPNames.SP_GUARDAR_EMPRESA_CERTIFICADO, p);
        return await r.ReadAsync()
            ? r.MapTo<GuardarCertificadoEmpresaResponse>()
            : new() { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado." };
    }

    public async Task<CertificadoVistaDto?> PrevisualizarAsync(int loteId, int certificadoPlantillaId)
    {
        var p = new List<SqlParameter>
        {
            new("@LoteId", loteId),
            new("@CertificadoPlantillaId", certificadoPlantillaId)
        };
        using var r = await _executor.ExecuteReaderAsync(SPNames.SP_PREVISUALIZAR_CERTIFICADO, p);
        if (!await r.ReadAsync()) return null;

        var dto = new CertificadoVistaDto
        {
            Cabecera = r.MapTo<CertificadoCabeceraDto>()
        };

        if (await r.NextResultAsync())
            while (await r.ReadAsync())
                dto.Secciones.Add(r.MapTo<CertificadoSeccionVistaDto>());

        if (await r.NextResultAsync())
            while (await r.ReadAsync())
                dto.Resultados.Add(r.MapTo<CertificadoResultadoVistaDto>());

        return dto;
    }

    public async Task<EmitirCertificadoResponse> EmitirAsync(EmitirCertificadoRequest request, string usuario)
    {
        var p = new List<SqlParameter>
        {
            new("@LoteId", request.LoteId),
            new("@CertificadoPlantillaId", request.CertificadoPlantillaId),
            new("@Usuario", usuario)
        };
        using var r = await _executor.ExecuteReaderAsync(SPNames.SP_EMITIR_CERTIFICADO, p);
        return await r.ReadAsync()
            ? r.MapTo<EmitirCertificadoResponse>()
            : new EmitirCertificadoResponse
            {
                CodigoResultado = -1,
                Mensaje = "El procedimiento no devolvió resultado."
            };
    }

    public async Task<CertificadoVistaDto?> ObtenerEmitidoAsync(int certificadoId)
    {
        var p = new List<SqlParameter> { new("@CertificadoId", certificadoId) };
        using var r = await _executor.ExecuteReaderAsync(SPNames.SP_OBTENER_CERTIFICADO_EMITIDO, p);
        if (!await r.ReadAsync()) return null;

        var dto = new CertificadoVistaDto
        {
            Cabecera = r.MapTo<CertificadoCabeceraDto>()
        };

        if (await r.NextResultAsync())
            while (await r.ReadAsync())
                dto.Secciones.Add(r.MapTo<CertificadoSeccionVistaDto>());

        if (await r.NextResultAsync())
            while (await r.ReadAsync())
                dto.Resultados.Add(r.MapTo<CertificadoResultadoVistaDto>());

        return dto;
    }

    public async Task<PlantillaCertificadoListaDto?> ObtenerPlantillaPredeterminadaAsync(int loteId)
    {
        var p = new List<SqlParameter> { new("@LoteId", loteId) };
        using var r = await _executor.ExecuteReaderAsync(
            SPNames.SP_OBTENER_PLANTILLA_PREDETERMINADA_CERTIFICADO,
            p);

        return await r.ReadAsync()
            ? r.MapTo<PlantillaCertificadoListaDto>()
            : null;
    }
    public async Task<PlantillaCertificadoOperacionResponse> EstablecerPlantillaPredeterminadaAsync(int certificadoPlantillaId, string usuario)
    {
        var p = new List<SqlParameter>
        {
            new("@CertificadoPlantillaId", certificadoPlantillaId),
            new("@Usuario", usuario)
        };

        using var r = await _executor.ExecuteReaderAsync(
            SPNames.SP_ESTABLECER_PLANTILLA_PREDETERMINADA_CERTIFICADO,
            p);

        return await r.ReadAsync()
            ? r.MapTo<PlantillaCertificadoOperacionResponse>()
            : new()
            {
                CodigoResultado = -1,
                Mensaje = "El procedimiento no devolvió resultado.",
                CertificadoPlantillaId = certificadoPlantillaId
            };
    }
}

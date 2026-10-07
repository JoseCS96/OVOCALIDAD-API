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

}
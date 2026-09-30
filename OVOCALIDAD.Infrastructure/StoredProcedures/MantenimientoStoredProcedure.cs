using Microsoft.Data.SqlClient;
using OVOCALIDAD.Application.DTOs.Mantenimientos;
using OVOCALIDAD.Infrastructure.Mappers;
using SPNames = OVOCALIDAD.Shared.Constants.StoredProcedures;

namespace OVOCALIDAD.Infrastructure.StoredProcedures;

public class MantenimientoStoredProcedure
{
    private readonly StoredProcedureExecutor _executor;
    public MantenimientoStoredProcedure(StoredProcedureExecutor executor) => _executor = executor;

    public async Task<IReadOnlyList<IngredienteMantenimientoDto>> ListarIngredientesAsync(IngredienteMantenimientoFiltro filtro)
    {
        var parametros = new List<SqlParameter>
        {
            new("@Busqueda", (object?)filtro.Busqueda ?? DBNull.Value),
            new("@Estado", (object?)filtro.Estado ?? DBNull.Value)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_LISTAR_INGREDIENTES, parametros);
        var items = new List<IngredienteMantenimientoDto>();
        while (await reader.ReadAsync()) items.Add(reader.MapTo<IngredienteMantenimientoDto>());
        return items;
    }

    public async Task<GuardarIngredienteResponse> GuardarIngredienteAsync(GuardarIngredienteRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@IngredienteId", (object?)request.IngredienteId ?? DBNull.Value),
            new("@IngredienteDescripcion", request.IngredienteDescripcion),
            new("@UnidadDeMedida", (object?)request.UnidadDeMedida ?? DBNull.Value),
            new("@Usuario", request.Usuario)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_GUARDAR_INGREDIENTE, parametros);
        return await reader.ReadAsync() ? reader.MapTo<GuardarIngredienteResponse>() : new GuardarIngredienteResponse { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado." };
    }

    public async Task<CambiarEstadoIngredienteResponse> CambiarEstadoIngredienteAsync(int ingredienteId, CambiarEstadoIngredienteRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@IngredienteId", ingredienteId),
            new("@Estado", request.Estado),
            new("@Usuario", request.Usuario)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_CAMBIAR_ESTADO_INGREDIENTE, parametros);
        return await reader.ReadAsync() ? reader.MapTo<CambiarEstadoIngredienteResponse>() : new CambiarEstadoIngredienteResponse { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado." };
    }

    public async Task<IReadOnlyList<CaracteristicaMantenimientoDto>> ListarCaracteristicasAsync(CaracteristicaMantenimientoFiltro filtro)
    {
        var parametros = new List<SqlParameter>
        {
            new("@Busqueda", (object?)filtro.Busqueda ?? DBNull.Value),
            new("@TipoCaractId", (object?)filtro.TipoCaractId ?? DBNull.Value),
            new("@Estado", (object?)filtro.Estado ?? DBNull.Value)
        };

        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_LISTAR_CARACTERISTICAS, parametros);
        var items = new List<CaracteristicaMantenimientoDto>();
        while (await reader.ReadAsync()) items.Add(reader.MapTo<CaracteristicaMantenimientoDto>());
        return items;
    }

    public async Task<CatalogosCaracteristicaMantenimientoDto> ObtenerCatalogosCaracteristicaAsync()
    {
        using var reader = await _executor.ExecuteReaderAsync(
            SPNames.SP_OBTENER_CATALOGOS_CARACTERISTICA,
            new List<SqlParameter>());

        var tipos = new List<TipoCaracteristicaMantenimientoDto>();
        while (await reader.ReadAsync()) tipos.Add(reader.MapTo<TipoCaracteristicaMantenimientoDto>());

        var metodos = new List<MetodoEnsayoMantenimientoDto>();
        if (await reader.NextResultAsync())
            while (await reader.ReadAsync()) metodos.Add(reader.MapTo<MetodoEnsayoMantenimientoDto>());

        return new CatalogosCaracteristicaMantenimientoDto
        {
            TiposCaracteristica = tipos,
            MetodosEnsayo = metodos
        };
    }

    public async Task<GuardarCaracteristicaResponse> GuardarCaracteristicaAsync(GuardarCaracteristicaRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@CaracteristicaId", (object?)request.CaracteristicaId ?? DBNull.Value),
            new("@CaracteristicaDescripcion", request.CaracteristicaDescripcion),
            new("@CaracteristicaUnidadDeMedida", (object?)request.CaracteristicaUnidadDeMedida ?? DBNull.Value),
            new("@TipoCaractId", request.TipoCaractId),
            new("@MetEnsayoId", (object?)request.MetEnsayoId ?? DBNull.Value),
            new("@Usuario", request.Usuario)
        };

        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_GUARDAR_CARACTERISTICA, parametros);
        return await reader.ReadAsync()
            ? reader.MapTo<GuardarCaracteristicaResponse>()
            : new GuardarCaracteristicaResponse { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado." };
    }

    public async Task<CambiarEstadoCaracteristicaResponse> CambiarEstadoCaracteristicaAsync(
        int caracteristicaId,
        CambiarEstadoCaracteristicaRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@CaracteristicaId", caracteristicaId),
            new("@Estado", request.Estado),
            new("@Usuario", request.Usuario)
        };

        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_CAMBIAR_ESTADO_CARACTERISTICA, parametros);
        return await reader.ReadAsync()
            ? reader.MapTo<CambiarEstadoCaracteristicaResponse>()
            : new CambiarEstadoCaracteristicaResponse { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado." };
    }

    public async Task<IReadOnlyList<TipoCaracteristicaMantenimientoDetalleDto>> ListarTiposCaracteristicaAsync(TipoCaracteristicaMantenimientoFiltro filtro)
    {
        var parametros = new List<SqlParameter>
        {
            new("@Busqueda", (object?)filtro.Busqueda ?? DBNull.Value),
            new("@Estado", (object?)filtro.Estado ?? DBNull.Value)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_LISTAR_TIPOS_CARACTERISTICA, parametros);
        var items = new List<TipoCaracteristicaMantenimientoDetalleDto>();
        while (await reader.ReadAsync()) items.Add(reader.MapTo<TipoCaracteristicaMantenimientoDetalleDto>());
        return items;
    }

    public async Task<GuardarTipoCaracteristicaResponse> GuardarTipoCaracteristicaAsync(GuardarTipoCaracteristicaRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@TipoCaractId", (object?)request.TipoCaractId ?? DBNull.Value),
            new("@TipoCaractDescripcion", request.TipoCaractDescripcion),
            new("@Usuario", request.Usuario)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_GUARDAR_TIPO_CARACTERISTICA, parametros);
        return await reader.ReadAsync() ? reader.MapTo<GuardarTipoCaracteristicaResponse>() : new GuardarTipoCaracteristicaResponse { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado." };
    }

    public async Task<CambiarEstadoTipoCaracteristicaResponse> CambiarEstadoTipoCaracteristicaAsync(int tipoCaractId, CambiarEstadoTipoCaracteristicaRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@TipoCaractId", tipoCaractId),
            new("@Estado", request.Estado),
            new("@Usuario", request.Usuario)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_CAMBIAR_ESTADO_TIPO_CARACTERISTICA, parametros);
        return await reader.ReadAsync() ? reader.MapTo<CambiarEstadoTipoCaracteristicaResponse>() : new CambiarEstadoTipoCaracteristicaResponse { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado." };
    }

    public async Task<IReadOnlyList<MetodoEnsayoMantenimientoDetalleDto>> ListarMetodosEnsayoAsync(MetodoEnsayoMantenimientoFiltro filtro)
    {
        var parametros = new List<SqlParameter>
        {
            new("@Busqueda", (object?)filtro.Busqueda ?? DBNull.Value),
            new("@Estado", (object?)filtro.Estado ?? DBNull.Value)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_LISTAR_METODOS_ENSAYO, parametros);
        var items = new List<MetodoEnsayoMantenimientoDetalleDto>();
        while (await reader.ReadAsync()) items.Add(reader.MapTo<MetodoEnsayoMantenimientoDetalleDto>());
        return items;
    }

    public async Task<GuardarMetodoEnsayoResponse> GuardarMetodoEnsayoAsync(GuardarMetodoEnsayoRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@MetEnsayoId", (object?)request.MetEnsayoId ?? DBNull.Value),
            new("@MetEnsayoDescripcion", request.MetEnsayoDescripcion),
            new("@Usuario", request.Usuario)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_GUARDAR_METODO_ENSAYO, parametros);
        return await reader.ReadAsync() ? reader.MapTo<GuardarMetodoEnsayoResponse>() : new GuardarMetodoEnsayoResponse { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado." };
    }

    public async Task<CambiarEstadoMetodoEnsayoResponse> CambiarEstadoMetodoEnsayoAsync(int metEnsayoId, CambiarEstadoMetodoEnsayoRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@MetEnsayoId", metEnsayoId),
            new("@Estado", request.Estado),
            new("@Usuario", request.Usuario)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_CAMBIAR_ESTADO_METODO_ENSAYO, parametros);
        return await reader.ReadAsync() ? reader.MapTo<CambiarEstadoMetodoEnsayoResponse>() : new CambiarEstadoMetodoEnsayoResponse { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado." };
    }
}

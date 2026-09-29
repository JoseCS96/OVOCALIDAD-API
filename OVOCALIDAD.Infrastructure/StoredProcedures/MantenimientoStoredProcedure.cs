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
}

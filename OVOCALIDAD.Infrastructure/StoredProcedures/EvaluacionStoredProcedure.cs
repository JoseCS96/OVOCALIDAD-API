using Microsoft.Data.SqlClient;
using OVOCALIDAD.Application.DTOs.Evaluaciones;
using OVOCALIDAD.Infrastructure.Mappers;
using SPNames = OVOCALIDAD.Shared.Constants.StoredProcedures;

namespace OVOCALIDAD.Infrastructure.StoredProcedures;

public class EvaluacionStoredProcedure
{
    private readonly StoredProcedureExecutor _executor;

    public EvaluacionStoredProcedure(StoredProcedureExecutor executor) => _executor = executor;

    public async Task<IniciarEvaluacionResponse> IniciarAsync(int evaluacionId, string usuario)
    {
        var parametros = new List<SqlParameter>
        {
            new("@EvaluacionId", evaluacionId),
            new("@Usuario", usuario)
        };

        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_INICIAR_EVALUACION, parametros);
        return await reader.ReadAsync() ? reader.MapTo<IniciarEvaluacionResponse>() : new IniciarEvaluacionResponse
        {
            CodigoResultado = -1,
            Mensaje = "El procedimiento no devolvió resultado."
        };
    }

    public async Task<PanelEvaluadorDto> ObtenerPanelAsync(string usuario)
    {
        var parametros = new List<SqlParameter>
        {
            new("@UsuarioEvaluador", usuario)
        };

        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_OBTENER_PANEL_EVALUADOR, parametros);

        var panel = new PanelEvaluadorDto();

        if (await reader.ReadAsync())
            panel.Indicadores = reader.MapTo<PanelEvaluadorIndicadoresDto>();

        if (await reader.NextResultAsync())
            while (await reader.ReadAsync())
                panel.PendientesDisponibles.Add(reader.MapTo<PanelEvaluacionItemDto>());

        if (await reader.NextResultAsync())
            while (await reader.ReadAsync())
                panel.MisEvaluaciones.Add(reader.MapTo<PanelEvaluacionItemDto>());

        if (await reader.NextResultAsync())
            while (await reader.ReadAsync())
                panel.AtendidasHoy.Add(reader.MapTo<PanelEvaluacionItemDto>());

        if (await reader.NextResultAsync())
            while (await reader.ReadAsync())
                panel.ResumenEstados.Add(reader.MapTo<PanelEvaluadorResumenEstadoDto>());

        return panel;
    }

    public async Task<EvaluacionDto?> ObtenerAsync(int evaluacionId)
    {
        var parametros = new List<SqlParameter> { new("@EvaluacionId", evaluacionId) };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_OBTENER_EVALUACION, parametros);

        if (!await reader.ReadAsync())
            return null;

        var cabecera = reader.MapTo<EvaluacionCabeceraDto>();
        var detalle = new List<EvaluacionDetalleDto>();

        if (await reader.NextResultAsync())
            while (await reader.ReadAsync())
                detalle.Add(reader.MapTo<EvaluacionDetalleDto>());

        var avance = new EvaluacionAvanceDto
        {
            TotalCaracteristicas = detalle.Count,
            TotalObligatorias = detalle.Count(x => x.EsObligatorio),
            ResultadosRegistrados = detalle.Count(x => x.ResultadoNumerico.HasValue || !string.IsNullOrWhiteSpace(x.ResultadoTexto)),
            ObligatoriasCompletas = detalle.Count(x => x.EsObligatorio && (x.ResultadoNumerico.HasValue || !string.IsNullOrWhiteSpace(x.ResultadoTexto)))
        };

        if (await reader.NextResultAsync() && await reader.ReadAsync())
        {
            var avanceSp = reader.MapTo<EvaluacionAvanceDto>();
            if (avanceSp.TotalCaracteristicas > 0 || avanceSp.TotalObligatorias > 0)
                avance = avanceSp;
        }

        return new EvaluacionDto { Cabecera = cabecera, Detalle = detalle, Avance = avance };
    }

    public async Task<GuardarResultadoResponse> GuardarResultadoAsync(int evaluacionId, GuardarResultadoRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@EvaluacionId", evaluacionId),
            new("@VersCaractId", request.VersCaractId),
            new("@ResultadoTexto", (object?)request.ResultadoTexto ?? DBNull.Value),
            new("@ResultadoNumerico", (object?)request.ResultadoNumerico ?? DBNull.Value),
            new("@Cumple", (object?)request.Cumple ?? DBNull.Value),
            new("@Observacion", (object?)request.Observacion ?? DBNull.Value),
            new("@Usuario", request.Usuario)
        };

        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_GUARDAR_RESULTADO, parametros);
        return await reader.ReadAsync() ? reader.MapTo<GuardarResultadoResponse>() : new GuardarResultadoResponse
        {
            CodigoResultado = -1,
            Mensaje = "El procedimiento no devolvió resultado."
        };
    }

    public async Task<CerrarEvaluacionResponse> CerrarAsync(int evaluacionId, CerrarEvaluacionRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@EvaluacionId", evaluacionId),
            new("@Usuario", request.Usuario)
        };

        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_CERRAR_EVALUACION, parametros);
        return await reader.ReadAsync() ? reader.MapTo<CerrarEvaluacionResponse>() : new CerrarEvaluacionResponse
        {
            CodigoResultado = -1,
            Mensaje = "El procedimiento no devolvió resultado."
        };
    }
}

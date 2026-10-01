using Microsoft.Data.SqlClient;
using System.Data;
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

    public async Task<List<PanelEvaluacionItemDto>> ListarEvaluacionesAsync(string usuario)
    {
        var parametros = new List<SqlParameter> { new("@Usuario", usuario) };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_LISTAR_EVALUACIONES_CALIDAD, parametros);
        var items = new List<PanelEvaluacionItemDto>();
        while (await reader.ReadAsync())
            items.Add(reader.MapTo<PanelEvaluacionItemDto>());
        return items;
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

    public async Task<GuardarResultadoResponse> GuardarResultadoAsync(int evaluacionId, GuardarResultadoRequest request, string usuario)
    {
        var parametros = new List<SqlParameter>
        {
            new("@EvaluacionId", evaluacionId),
            new("@VersCaractId", request.VersCaractId),
            new("@ResultadoTexto", (object?)request.ResultadoTexto ?? DBNull.Value),
            new("@ResultadoNumerico", (object?)request.ResultadoNumerico ?? DBNull.Value),
            new("@Cumple", (object?)request.Cumple ?? DBNull.Value),
            new("@Observacion", (object?)request.Observacion ?? DBNull.Value),
            new("@Usuario", usuario)
        };

        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_GUARDAR_RESULTADO, parametros);
        return await reader.ReadAsync() ? reader.MapTo<GuardarResultadoResponse>() : new GuardarResultadoResponse
        {
            CodigoResultado = -1,
            Mensaje = "El procedimiento no devolvió resultado."
        };
    }


    public async Task<TerminarEvaluacionResponse> TerminarAsync(int evaluacionId, string usuario)
    {
        var parametros = new List<SqlParameter>
        {
            new("@EvaluacionId", evaluacionId),
            new("@Usuario", usuario)
        };

        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_TERMINAR_EVALUACION, parametros);
        return await reader.ReadAsync() ? reader.MapTo<TerminarEvaluacionResponse>() : new TerminarEvaluacionResponse
        {
            CodigoResultado = -1,
            Mensaje = "El procedimiento no devolvió resultado."
        };
    }

    public async Task<SolicitarReaperturaResponse> SolicitarReaperturaAsync(int evaluacionId, string motivo, string usuario)
    {
        var parametros = new List<SqlParameter>
        {
            new("@EvaluacionId", evaluacionId),
            new("@Motivo", motivo),
            new("@Usuario", usuario)
        };

        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_SOLICITAR_REAPERTURA_EVALUACION, parametros);
        return await reader.ReadAsync() ? reader.MapTo<SolicitarReaperturaResponse>() : new SolicitarReaperturaResponse
        {
            CodigoResultado = -1,
            Mensaje = "El procedimiento no devolvió resultado."
        };
    }

    public async Task<ResolverReaperturaResponse> ResolverReaperturaAsync(int solicitudReaperturaId, ResolverReaperturaRequest request, string usuario)
    {
        var parametros = new List<SqlParameter>
        {
            new("@SolicitudReaperturaId", solicitudReaperturaId),
            new("@Aprobar", request.Aprobar),
            new("@Observacion", (object?)request.Observacion ?? DBNull.Value),
            new("@Usuario", usuario)
        };

        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_RESOLVER_REAPERTURA_EVALUACION, parametros);
        return await reader.ReadAsync() ? reader.MapTo<ResolverReaperturaResponse>() : new ResolverReaperturaResponse
        {
            CodigoResultado = -1,
            Mensaje = "El procedimiento no devolvió resultado."
        };
    }


    public async Task<List<SolicitudReaperturaItemDto>> ListarSolicitudesReaperturaAsync(string usuario, string? estadoSolicitud)
    {
        var parametros = new List<SqlParameter>
        {
            new("@Usuario", usuario),
            new("@EstadoSolicitud", (object?)estadoSolicitud ?? DBNull.Value)
        };

        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_LISTAR_SOLICITUDES_REAPERTURA, parametros);
        var items = new List<SolicitudReaperturaItemDto>();
        while (await reader.ReadAsync())
            items.Add(reader.MapTo<SolicitudReaperturaItemDto>());

        return items;
    }

    public async Task<SolicitudReaperturaDetalleDto?> ObtenerSolicitudReaperturaAsync(int solicitudReaperturaId, string usuario)
    {
        var parametros = new List<SqlParameter>
        {
            new("@SolicitudReaperturaId", solicitudReaperturaId),
            new("@Usuario", usuario)
        };

        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_OBTENER_SOLICITUD_REAPERTURA, parametros);
        if (!await reader.ReadAsync())
            return null;

        var detalle = reader.MapTo<SolicitudReaperturaDetalleDto>();
        if (detalle.CodigoResultado != 0)
            return detalle;

        if (await reader.NextResultAsync())
            while (await reader.ReadAsync())
                detalle.Lecturas.Add(reader.MapTo<SolicitudReaperturaLecturaDto>());

        return detalle;
    }

    public async Task<CerrarEvaluacionResponse> CerrarAsync(int evaluacionId, string usuario)
    {
        var parametros = new List<SqlParameter>
        {
            new("@EvaluacionId", evaluacionId),
            new("@Usuario", usuario)
        };

        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_CERRAR_EVALUACION, parametros);
        return await reader.ReadAsync() ? reader.MapTo<CerrarEvaluacionResponse>() : new CerrarEvaluacionResponse
        {
            CodigoResultado = -1,
            Mensaje = "El procedimiento no devolvió resultado."
        };
    }

    private static SqlParameter CrearEvaluacionesParameter(IReadOnlyCollection<int> evaluacionIds)
    {
        var table = new DataTable();
        table.Columns.Add("EvaluacionId", typeof(int));
        foreach (var id in evaluacionIds.Distinct())
            table.Rows.Add(id);

        return new SqlParameter("@Evaluaciones", SqlDbType.Structured)
        {
            TypeName = "dbo.TT_EVALUACION_ID",
            Value = table
        };
    }

    public async Task<List<EvaluacionPendienteCalculoDto>> ListarPendientesCalculoAsync()
    {
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_LISTAR_EVALUACIONES_PENDIENTES_CALCULO);
        var items = new List<EvaluacionPendienteCalculoDto>();
        while (await reader.ReadAsync())
            items.Add(reader.MapTo<EvaluacionPendienteCalculoDto>());
        return items;
    }

    public async Task<PrecalculoEvaluacionesResponse> PrecalcularAsync(IReadOnlyCollection<int> evaluacionIds)
    {
        var parametros = new List<SqlParameter> { CrearEvaluacionesParameter(evaluacionIds) };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_PRECALCULAR_DISPOSICION_EVALUACIONES, parametros);

        var response = new PrecalculoEvaluacionesResponse();
        while (await reader.ReadAsync())
            response.Evaluaciones.Add(reader.MapTo<PrecalculoEvaluacionDto>());

        if (await reader.NextResultAsync())
            while (await reader.ReadAsync())
                response.Detalle.Add(reader.MapTo<PrecalculoDetalleDto>());

        return response;
    }

    public async Task<List<ConsolidacionEvaluacionResultadoDto>> ConsolidarAsync(
        IReadOnlyCollection<int> evaluacionIds,
        string usuario,
        string? observacion)
    {
        var parametros = new List<SqlParameter>
        {
            CrearEvaluacionesParameter(evaluacionIds),
            new("@Usuario", usuario),
            new("@Observacion", (object?)observacion ?? DBNull.Value)
        };

        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_CONSOLIDAR_EVALUACIONES, parametros);
        var items = new List<ConsolidacionEvaluacionResultadoDto>();
        while (await reader.ReadAsync())
            items.Add(reader.MapTo<ConsolidacionEvaluacionResultadoDto>());
        return items;
    }

}

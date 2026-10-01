using OVOCALIDAD.Application.DTOs.Evaluaciones;

namespace OVOCALIDAD.Application.Interfaces;

public interface IEvaluacionRepository
{
    Task<IniciarEvaluacionResponse> IniciarAsync(int evaluacionId, string usuario);
    Task<PanelEvaluadorDto> ObtenerPanelAsync(string usuario);
    Task<List<PanelEvaluacionItemDto>> ListarEvaluacionesAsync(string usuario);
    Task<EvaluacionDto?> ObtenerAsync(int evaluacionId);
    Task<GuardarResultadoResponse> GuardarResultadoAsync(int evaluacionId, GuardarResultadoRequest request, string usuario);
    Task<CerrarEvaluacionResponse> CerrarAsync(int evaluacionId, string usuario);
    Task<TerminarEvaluacionResponse> TerminarAsync(int evaluacionId, string usuario);
    Task<SolicitarReaperturaResponse> SolicitarReaperturaAsync(int evaluacionId, string motivo, string usuario);
    Task<ResolverReaperturaResponse> ResolverReaperturaAsync(int solicitudReaperturaId, ResolverReaperturaRequest request, string usuario);
    Task<List<SolicitudReaperturaItemDto>> ListarSolicitudesReaperturaAsync(string usuario, string? estadoSolicitud);
    Task<SolicitudReaperturaDetalleDto?> ObtenerSolicitudReaperturaAsync(int solicitudReaperturaId, string usuario);
    Task<List<EvaluacionPendienteCalculoDto>> ListarPendientesCalculoAsync();
    Task<PrecalculoEvaluacionesResponse> PrecalcularAsync(IReadOnlyCollection<int> evaluacionIds);
    Task<List<ConsolidacionEvaluacionResultadoDto>> ConsolidarAsync(IReadOnlyCollection<int> evaluacionIds, string usuario, string? observacion);
}

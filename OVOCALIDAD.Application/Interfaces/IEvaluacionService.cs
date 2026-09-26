using OVOCALIDAD.Application.DTOs.Evaluaciones;

namespace OVOCALIDAD.Application.Interfaces;

public interface IEvaluacionService
{
    Task<IniciarEvaluacionResponse> IniciarAsync(int evaluacionId, string usuario);
    Task<PanelEvaluadorDto> ObtenerPanelAsync(string usuario);
    Task<EvaluacionDto?> ObtenerAsync(int evaluacionId);
    Task<GuardarResultadoResponse> GuardarResultadoAsync(int evaluacionId, GuardarResultadoRequest request, string usuario);
    Task<CerrarEvaluacionResponse> CerrarAsync(int evaluacionId, string usuario);
    Task<TerminarEvaluacionResponse> TerminarAsync(int evaluacionId, string usuario);
    Task<SolicitarReaperturaResponse> SolicitarReaperturaAsync(int evaluacionId, string motivo, string usuario);
    Task<ResolverReaperturaResponse> ResolverReaperturaAsync(int solicitudReaperturaId, ResolverReaperturaRequest request, string usuario);
}

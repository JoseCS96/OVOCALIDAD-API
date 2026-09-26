using OVOCALIDAD.Application.DTOs.Evaluaciones;

namespace OVOCALIDAD.Application.Interfaces;

public interface IEvaluacionService
{
    Task<IniciarEvaluacionResponse> IniciarAsync(int evaluacionId, string usuario);
    Task<PanelEvaluadorDto> ObtenerPanelAsync(string usuario);
    Task<EvaluacionDto?> ObtenerAsync(int evaluacionId);
    Task<GuardarResultadoResponse> GuardarResultadoAsync(int evaluacionId, GuardarResultadoRequest request);
    Task<CerrarEvaluacionResponse> CerrarAsync(int evaluacionId, CerrarEvaluacionRequest request);
}

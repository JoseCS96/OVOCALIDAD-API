using OVOCALIDAD.Application.DTOs.Evaluaciones;

namespace OVOCALIDAD.Application.Interfaces;

public interface IEvaluacionRepository
{
    Task<IniciarEvaluacionResponse> IniciarAsync(int evaluacionId, IniciarEvaluacionRequest request);
    Task<EvaluacionDto?> ObtenerAsync(int evaluacionId);
    Task<GuardarResultadoResponse> GuardarResultadoAsync(int evaluacionId, GuardarResultadoRequest request);
}

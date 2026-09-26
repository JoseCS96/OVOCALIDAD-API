using OVOCALIDAD.Application.DTOs.Evaluaciones;
using OVOCALIDAD.Application.Interfaces;

namespace OVOCALIDAD.Application.Services;

public class EvaluacionService : IEvaluacionService
{
    private readonly IEvaluacionRepository _repository;

    public EvaluacionService(IEvaluacionRepository repository) => _repository = repository;

    public Task<IniciarEvaluacionResponse> IniciarAsync(int evaluacionId, string usuario) =>
        _repository.IniciarAsync(evaluacionId, usuario);

    public Task<PanelEvaluadorDto> ObtenerPanelAsync(string usuario) =>
        _repository.ObtenerPanelAsync(usuario);

    public Task<EvaluacionDto?> ObtenerAsync(int evaluacionId) =>
        _repository.ObtenerAsync(evaluacionId);

    public Task<GuardarResultadoResponse> GuardarResultadoAsync(int evaluacionId, GuardarResultadoRequest request) =>
        _repository.GuardarResultadoAsync(evaluacionId, request);

    public Task<CerrarEvaluacionResponse> CerrarAsync(int evaluacionId, CerrarEvaluacionRequest request) =>
        _repository.CerrarAsync(evaluacionId, request);
}

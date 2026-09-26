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

    public Task<GuardarResultadoResponse> GuardarResultadoAsync(int evaluacionId, GuardarResultadoRequest request, string usuario) =>
        _repository.GuardarResultadoAsync(evaluacionId, request, usuario);

    public Task<CerrarEvaluacionResponse> CerrarAsync(int evaluacionId, string usuario) =>
        _repository.CerrarAsync(evaluacionId, usuario);

    public Task<TerminarEvaluacionResponse> TerminarAsync(int evaluacionId, string usuario) =>
        _repository.TerminarAsync(evaluacionId, usuario);

    public Task<SolicitarReaperturaResponse> SolicitarReaperturaAsync(int evaluacionId, string motivo, string usuario) =>
        _repository.SolicitarReaperturaAsync(evaluacionId, motivo, usuario);

    public Task<ResolverReaperturaResponse> ResolverReaperturaAsync(int solicitudReaperturaId, ResolverReaperturaRequest request, string usuario) =>
        _repository.ResolverReaperturaAsync(solicitudReaperturaId, request, usuario);
}

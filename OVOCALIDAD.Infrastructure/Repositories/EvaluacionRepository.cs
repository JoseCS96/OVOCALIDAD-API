using OVOCALIDAD.Application.DTOs.Evaluaciones;
using OVOCALIDAD.Application.Interfaces;
using OVOCALIDAD.Infrastructure.StoredProcedures;

namespace OVOCALIDAD.Infrastructure.Repositories;

public class EvaluacionRepository : IEvaluacionRepository
{
    private readonly EvaluacionStoredProcedure _storedProcedure;

    public EvaluacionRepository(EvaluacionStoredProcedure storedProcedure) => _storedProcedure = storedProcedure;

    public Task<IniciarEvaluacionResponse> IniciarAsync(int evaluacionId, string usuario) =>
        _storedProcedure.IniciarAsync(evaluacionId, usuario);

    public Task<PanelEvaluadorDto> ObtenerPanelAsync(string usuario) =>
        _storedProcedure.ObtenerPanelAsync(usuario);

    public Task<EvaluacionDto?> ObtenerAsync(int evaluacionId) =>
        _storedProcedure.ObtenerAsync(evaluacionId);

    public Task<GuardarResultadoResponse> GuardarResultadoAsync(int evaluacionId, GuardarResultadoRequest request, string usuario) =>
        _storedProcedure.GuardarResultadoAsync(evaluacionId, request, usuario);

    public Task<CerrarEvaluacionResponse> CerrarAsync(int evaluacionId, string usuario) =>
        _storedProcedure.CerrarAsync(evaluacionId, usuario);
}

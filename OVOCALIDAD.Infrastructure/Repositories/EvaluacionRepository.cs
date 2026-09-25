using OVOCALIDAD.Application.DTOs.Evaluaciones;
using OVOCALIDAD.Application.Interfaces;
using OVOCALIDAD.Infrastructure.StoredProcedures;

namespace OVOCALIDAD.Infrastructure.Repositories;

public class EvaluacionRepository : IEvaluacionRepository
{
    private readonly EvaluacionStoredProcedure _storedProcedure;

    public EvaluacionRepository(EvaluacionStoredProcedure storedProcedure) => _storedProcedure = storedProcedure;

    public Task<IniciarEvaluacionResponse> IniciarAsync(int evaluacionId, IniciarEvaluacionRequest request) =>
        _storedProcedure.IniciarAsync(evaluacionId, request);

    public Task<EvaluacionDto?> ObtenerAsync(int evaluacionId) =>
        _storedProcedure.ObtenerAsync(evaluacionId);

    public Task<GuardarResultadoResponse> GuardarResultadoAsync(int evaluacionId, GuardarResultadoRequest request) =>
        _storedProcedure.GuardarResultadoAsync(evaluacionId, request);

    public Task<CerrarEvaluacionResponse> CerrarAsync(int evaluacionId, CerrarEvaluacionRequest request) =>
        _storedProcedure.CerrarAsync(evaluacionId, request);
}

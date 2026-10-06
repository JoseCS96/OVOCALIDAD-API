using OVOCALIDAD.Application.DTOs.Evaluaciones;
using OVOCALIDAD.Application.Interfaces;
using OVOCALIDAD.Infrastructure.StoredProcedures;

namespace OVOCALIDAD.Infrastructure.Repositories;

public class EvaluacionRepository : IEvaluacionRepository
{
    private readonly EvaluacionStoredProcedure _storedProcedure;

    public EvaluacionRepository(EvaluacionStoredProcedure storedProcedure) => _storedProcedure = storedProcedure;

    public Task<CrearEvaluacionResponse> CrearAsync(CrearEvaluacionRequest request, string usuario) =>
        _storedProcedure.CrearAsync(request, usuario);

    public Task<IniciarEvaluacionResponse> IniciarAsync(int evaluacionId, string usuario) =>
        _storedProcedure.IniciarAsync(evaluacionId, usuario);

    public Task<PanelEvaluadorDto> ObtenerPanelAsync(string usuario) =>
        _storedProcedure.ObtenerPanelAsync(usuario);

    public Task<List<PanelEvaluacionItemDto>> ListarEvaluacionesAsync(string usuario) =>
        _storedProcedure.ListarEvaluacionesAsync(usuario);

    public Task<RutaEvaluacionLoteDto> ObtenerRutaLoteAsync(int loteId) =>
        _storedProcedure.ObtenerRutaLoteAsync(loteId);

    public Task<EvaluacionDto?> ObtenerAsync(int evaluacionId) =>
        _storedProcedure.ObtenerAsync(evaluacionId);

    public Task<GuardarResultadoResponse> GuardarResultadoAsync(int evaluacionId, GuardarResultadoRequest request, string usuario) =>
        _storedProcedure.GuardarResultadoAsync(evaluacionId, request, usuario);

    public Task<CerrarEvaluacionResponse> CerrarAsync(int evaluacionId, string usuario) =>
        _storedProcedure.CerrarAsync(evaluacionId, usuario);

    public Task<TerminarEvaluacionResponse> TerminarAsync(int evaluacionId, string usuario) =>
        _storedProcedure.TerminarAsync(evaluacionId, usuario);

    public Task<SolicitarReaperturaResponse> SolicitarReaperturaAsync(int evaluacionId, string motivo, string usuario) =>
        _storedProcedure.SolicitarReaperturaAsync(evaluacionId, motivo, usuario);

    public Task<ResolverReaperturaResponse> ResolverReaperturaAsync(int solicitudReaperturaId, ResolverReaperturaRequest request, string usuario) =>
        _storedProcedure.ResolverReaperturaAsync(solicitudReaperturaId, request, usuario);

    public Task<List<SolicitudReaperturaItemDto>> ListarSolicitudesReaperturaAsync(string usuario, string? estadoSolicitud) =>
        _storedProcedure.ListarSolicitudesReaperturaAsync(usuario, estadoSolicitud);

    public Task<SolicitudReaperturaDetalleDto?> ObtenerSolicitudReaperturaAsync(int solicitudReaperturaId, string usuario) =>
        _storedProcedure.ObtenerSolicitudReaperturaAsync(solicitudReaperturaId, usuario);

    public Task<List<EvaluacionPendienteCalculoDto>> ListarPendientesCalculoAsync() =>
        _storedProcedure.ListarPendientesCalculoAsync();

    public Task<PrecalculoEvaluacionesResponse> PrecalcularAsync(IReadOnlyCollection<int> evaluacionIds) =>
        _storedProcedure.PrecalcularAsync(evaluacionIds);

    public Task<List<ConsolidacionEvaluacionResultadoDto>> ConsolidarAsync(IReadOnlyCollection<int> evaluacionIds, string usuario, string? observacion) =>
        _storedProcedure.ConsolidarAsync(evaluacionIds, usuario, observacion);
}

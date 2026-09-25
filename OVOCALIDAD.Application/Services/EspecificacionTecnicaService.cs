using OVOCALIDAD.Application.DTOs.EspecificacionesTecnicas;
using OVOCALIDAD.Application.Interfaces;

namespace OVOCALIDAD.Application.Services;

public class EspecificacionTecnicaService : IEspecificacionTecnicaService
{
    private readonly IEspecificacionTecnicaRepository _repository;

    public EspecificacionTecnicaService(IEspecificacionTecnicaRepository repository)
    {
        _repository = repository;
    }

    public Task<CrearEspecificacionTecnicaResponse> CrearAsync(CrearEspecificacionTecnicaRequest request) =>
        _repository.CrearAsync(request);

    public Task<CatalogosEspecificacionTecnicaDto> ObtenerCatalogosAsync() =>
        _repository.ObtenerCatalogosAsync();

    public Task<SeccionesEtCatalogoDto> ObtenerSeccionesAsync() =>
        _repository.ObtenerSeccionesAsync();

    public Task<CrearSeccionEtResponse> CrearSeccionAsync(CrearSeccionEtRequest request) =>
        _repository.CrearSeccionAsync(request);

    public Task<DetalleEspecificacionTecnicaDto?> ObtenerDetalleAsync(int versionId) =>
        _repository.ObtenerDetalleAsync(versionId);
    public Task<GuardarInformacionGeneralEtResponse> GuardarInformacionGeneralAsync(int versionId, GuardarInformacionGeneralEtRequest request) =>
        _repository.GuardarInformacionGeneralAsync(versionId, request);

    public Task<GuardarCaracteristicaEtResponse> GuardarCaracteristicaAsync(int versionId, GuardarCaracteristicaEtRequest request) =>
        _repository.GuardarCaracteristicaAsync(versionId, request);

    public Task<EliminarCaracteristicaEtResponse> EliminarCaracteristicaAsync(int versionId, int versCaractId, EliminarCaracteristicaEtRequest request) =>
        _repository.EliminarCaracteristicaAsync(versionId, versCaractId, request);

    public Task<IReadOnlyList<EspecificacionTecnicaListadoDto>> ListarAsync(ListarEspecificacionesTecnicasFiltro filtro) => _repository.ListarAsync(filtro);
}

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

    public Task<CatalogosEspecificacionTecnicaDto> ObtenerCatalogosAsync() =>
        _repository.ObtenerCatalogosAsync();

    public Task<DetalleEspecificacionTecnicaDto?> ObtenerDetalleAsync(int versionId) =>
        _repository.ObtenerDetalleAsync(versionId);
    public Task<GuardarInformacionGeneralEtResponse> GuardarInformacionGeneralAsync(int versionId, GuardarInformacionGeneralEtRequest request) =>
        _repository.GuardarInformacionGeneralAsync(versionId, request);

    public Task<GuardarCaracteristicaEtResponse> GuardarCaracteristicaAsync(int versionId, GuardarCaracteristicaEtRequest request) =>
        _repository.GuardarCaracteristicaAsync(versionId, request);

    public Task<EliminarCaracteristicaEtResponse> EliminarCaracteristicaAsync(int versionId, int versCaractId, EliminarCaracteristicaEtRequest request) =>
        _repository.EliminarCaracteristicaAsync(versionId, versCaractId, request);

}

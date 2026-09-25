using OVOCALIDAD.Application.DTOs.EspecificacionesTecnicas;
using OVOCALIDAD.Application.Interfaces;
using OVOCALIDAD.Infrastructure.StoredProcedures;

namespace OVOCALIDAD.Infrastructure.Repositories;

public class EspecificacionTecnicaRepository : IEspecificacionTecnicaRepository
{
    private readonly EspecificacionTecnicaStoredProcedure _storedProcedure;

    public EspecificacionTecnicaRepository(EspecificacionTecnicaStoredProcedure storedProcedure)
    {
        _storedProcedure = storedProcedure;
    }

    public Task<CatalogosEspecificacionTecnicaDto> ObtenerCatalogosAsync() =>
        _storedProcedure.ObtenerCatalogosAsync();

    public Task<DetalleEspecificacionTecnicaDto?> ObtenerDetalleAsync(int versionId) =>
        _storedProcedure.ObtenerDetalleAsync(versionId);
    public Task<GuardarInformacionGeneralEtResponse> GuardarInformacionGeneralAsync(int versionId, GuardarInformacionGeneralEtRequest request) =>
        _storedProcedure.GuardarInformacionGeneralAsync(versionId, request);

    public Task<GuardarCaracteristicaEtResponse> GuardarCaracteristicaAsync(int versionId, GuardarCaracteristicaEtRequest request) =>
        _storedProcedure.GuardarCaracteristicaAsync(versionId, request);

    public Task<EliminarCaracteristicaEtResponse> EliminarCaracteristicaAsync(int versionId, int versCaractId, EliminarCaracteristicaEtRequest request) =>
        _storedProcedure.EliminarCaracteristicaAsync(versionId, versCaractId, request);

    public Task<IReadOnlyList<EspecificacionTecnicaListadoDto>> ListarAsync(ListarEspecificacionesTecnicasFiltro filtro) => _storedProcedure.ListarAsync(filtro);
}

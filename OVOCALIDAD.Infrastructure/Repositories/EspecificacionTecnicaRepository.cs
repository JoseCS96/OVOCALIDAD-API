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
}

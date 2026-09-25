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
}

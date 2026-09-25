using OVOCALIDAD.Application.DTOs.EspecificacionesTecnicas;

namespace OVOCALIDAD.Application.Interfaces;

public interface IEspecificacionTecnicaRepository
{
    Task<CatalogosEspecificacionTecnicaDto> ObtenerCatalogosAsync();
}

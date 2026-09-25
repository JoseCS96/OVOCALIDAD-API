using OVOCALIDAD.Application.DTOs.EspecificacionesTecnicas;

namespace OVOCALIDAD.Application.Interfaces;

public interface IEspecificacionTecnicaService
{
    Task<CatalogosEspecificacionTecnicaDto> ObtenerCatalogosAsync();
}

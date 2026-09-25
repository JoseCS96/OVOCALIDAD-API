using Microsoft.AspNetCore.Mvc;
using OVOCALIDAD.Application.DTOs.EspecificacionesTecnicas;
using OVOCALIDAD.Application.Interfaces;

namespace OVOCALIDAD.Api.Controllers.EspecificacionesTecnicas;

[ApiController]
[Route("api/especificaciones-tecnicas")]
public class EspecificacionTecnicaController : ControllerBase
{
    private readonly IEspecificacionTecnicaService _service;

    public EspecificacionTecnicaController(IEspecificacionTecnicaService service)
    {
        _service = service;
    }

    [HttpGet("catalogos")]
    [ProducesResponseType(typeof(CatalogosEspecificacionTecnicaDto), StatusCodes.Status200OK)]
    public async Task<ActionResult<CatalogosEspecificacionTecnicaDto>> Catalogos()
    {
        return Ok(await _service.ObtenerCatalogosAsync());
    }

    [HttpGet("{versionId:int}")]
    [ProducesResponseType(typeof(DetalleEspecificacionTecnicaDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<DetalleEspecificacionTecnicaDto>> ObtenerDetalle(int versionId)
    {
        var detalle = await _service.ObtenerDetalleAsync(versionId);
        return detalle is null ? NotFound() : Ok(detalle);
    }
}

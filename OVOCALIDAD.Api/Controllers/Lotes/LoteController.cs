using Microsoft.AspNetCore.Mvc;
using OVOCALIDAD.Application.DTOs.Lotes;
using OVOCALIDAD.Application.Interfaces;

namespace OVOCALIDAD.Api.Controllers.Lotes;

[ApiController]
[Route("api/lotes")]
public class LoteController : ControllerBase
{
    private readonly ILoteService _loteService;

    public LoteController(ILoteService loteService)
    {
        _loteService = loteService;
    }

    [HttpGet]
    [ProducesResponseType(typeof(IReadOnlyList<LoteListadoDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IReadOnlyList<LoteListadoDto>>> Listar(
        [FromQuery] ListarLotesFiltro filtro)
    {
        var lotes = await _loteService.ListarLotesAsync(filtro);

        return Ok(lotes);
    }

    [HttpGet("{loteId:int}")]
    [ProducesResponseType(typeof(DetalleLoteDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<DetalleLoteDto>> ObtenerDetalle(int loteId)
    {
        var detalle = await _loteService.ObtenerDetalleAsync(loteId);
        return detalle is null ? NotFound() : Ok(detalle);
    }

    [HttpGet("catalogos")]
    [ProducesResponseType(typeof(CatalogosLoteDto), StatusCodes.Status200OK)]
    public async Task<ActionResult<CatalogosLoteDto>> Catalogos()
    {
        return Ok(await _loteService.ObtenerCatalogosAsync());
    }

    [HttpPost("generar")]
    [ProducesResponseType(typeof(GenerarLoteResponse), StatusCodes.Status200OK)]
    public async Task<ActionResult<GenerarLoteResponse>> Generar(
        [FromBody] GenerarLoteRequest request)
    {
        var response = await _loteService.GenerarLoteAsync(request);

        return Ok(response);
    }
}

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

    [HttpPost("generar")]
    [ProducesResponseType(typeof(GenerarLoteResponse), StatusCodes.Status200OK)]
    public async Task<ActionResult<GenerarLoteResponse>> Generar(
        [FromBody] GenerarLoteRequest request)
    {
        var response = await _loteService.GenerarLoteAsync(request);

        return Ok(response);
    }
}
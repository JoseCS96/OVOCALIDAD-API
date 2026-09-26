using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OVOCALIDAD.Application.DTOs.Evaluaciones;
using OVOCALIDAD.Application.Interfaces;

namespace OVOCALIDAD.Api.Controllers.Evaluaciones;

[ApiController]
[Authorize]
[Route("api/evaluaciones")]
public class EvaluacionController : ControllerBase
{
    private readonly IEvaluacionService _service;

    public EvaluacionController(IEvaluacionService service) => _service = service;

    [HttpGet("mi-panel")]
    public async Task<ActionResult<PanelEvaluadorDto>> ObtenerMiPanel()
    {
        var usuario = User.Identity?.Name;

        if (string.IsNullOrWhiteSpace(usuario))
            return Unauthorized();

        var response = await _service.ObtenerPanelAsync(usuario);
        return Ok(response);
    }

    [HttpPost("{evaluacionId:int}/iniciar")]
    public async Task<ActionResult<IniciarEvaluacionResponse>> Iniciar(int evaluacionId)
    {
        var usuario = User.Identity?.Name;

        if (string.IsNullOrWhiteSpace(usuario))
            return Unauthorized();

        var response = await _service.IniciarAsync(evaluacionId, usuario);
        return Ok(response);
    }

    [HttpGet("{evaluacionId:int}")]
    public async Task<ActionResult<EvaluacionDto>> Obtener(int evaluacionId)
    {
        var response = await _service.ObtenerAsync(evaluacionId);
        return response is null ? NotFound() : Ok(response);
    }

    [HttpPut("{evaluacionId:int}/resultados")]
    public async Task<ActionResult<GuardarResultadoResponse>> GuardarResultado(
        int evaluacionId,
        [FromBody] GuardarResultadoRequest request)
    {
        var response = await _service.GuardarResultadoAsync(evaluacionId, request);
        return Ok(response);
    }

    [HttpPost("{evaluacionId:int}/cerrar")]
    public async Task<ActionResult<CerrarEvaluacionResponse>> Cerrar(
        int evaluacionId,
        [FromBody] CerrarEvaluacionRequest request)
    {
        var response = await _service.CerrarAsync(evaluacionId, request);
        return Ok(response);
    }
}

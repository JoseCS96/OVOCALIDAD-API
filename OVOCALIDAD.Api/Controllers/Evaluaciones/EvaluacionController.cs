using Microsoft.AspNetCore.Mvc;
using OVOCALIDAD.Application.DTOs.Evaluaciones;
using OVOCALIDAD.Application.Interfaces;

namespace OVOCALIDAD.Api.Controllers.Evaluaciones;

[ApiController]
[Route("api/evaluaciones")]
public class EvaluacionController : ControllerBase
{
    private readonly IEvaluacionService _service;

    public EvaluacionController(IEvaluacionService service) => _service = service;

    [HttpPost("{evaluacionId:int}/iniciar")]
    public async Task<ActionResult<IniciarEvaluacionResponse>> Iniciar(
        int evaluacionId,
        [FromBody] IniciarEvaluacionRequest request)
    {
        var response = await _service.IniciarAsync(evaluacionId, request);
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

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
    private readonly ISeguridadService _seguridadService;

    public EvaluacionController(
        IEvaluacionService service,
        ISeguridadService seguridadService)
    {
        _service = service;
        _seguridadService = seguridadService;
    }

    [HttpGet("mi-panel")]
    public async Task<ActionResult<PanelEvaluadorDto>> ObtenerMiPanel()
    {
        var usuario = User.Identity?.Name;
        if (string.IsNullOrWhiteSpace(usuario)) return Unauthorized();
        if (!await TienePermisoAsync(usuario, "EVALUACION.VER")) return Forbid();

        var response = await _service.ObtenerPanelAsync(usuario);
        return Ok(response);
    }

    [HttpPost("{evaluacionId:int}/iniciar")]
    public async Task<ActionResult<IniciarEvaluacionResponse>> Iniciar(int evaluacionId)
    {
        var usuario = User.Identity?.Name;
        if (string.IsNullOrWhiteSpace(usuario)) return Unauthorized();
        if (!await TienePermisoAsync(usuario, "EVALUACION.INICIAR")) return Forbid();

        var response = await _service.IniciarAsync(evaluacionId, usuario);
        return Ok(response);
    }

    [HttpGet("{evaluacionId:int}")]
    public async Task<ActionResult<EvaluacionDto>> Obtener(int evaluacionId)
    {
        var usuario = User.Identity?.Name;
        if (string.IsNullOrWhiteSpace(usuario)) return Unauthorized();
        if (!await TienePermisoAsync(usuario, "EVALUACION.VER")) return Forbid();

        var response = await _service.ObtenerAsync(evaluacionId);
        return response is null ? NotFound() : Ok(response);
    }

    [HttpPut("{evaluacionId:int}/resultados")]
    public async Task<ActionResult<GuardarResultadoResponse>> GuardarResultado(
        int evaluacionId,
        [FromBody] GuardarResultadoRequest request)
    {
        var usuario = User.Identity?.Name;
        if (string.IsNullOrWhiteSpace(usuario)) return Unauthorized();
        if (!await TienePermisoAsync(usuario, "RESULTADO.REGISTRAR")) return Forbid();

        var response = await _service.GuardarResultadoAsync(evaluacionId, request, usuario);
        return Ok(response);
    }

    [HttpPost("{evaluacionId:int}/terminar")]
    public async Task<ActionResult<TerminarEvaluacionResponse>> Terminar(int evaluacionId)
    {
        var usuario = User.Identity?.Name;
        if (string.IsNullOrWhiteSpace(usuario)) return Unauthorized();
        if (!await TienePermisoAsync(usuario, "EVALUACION.TERMINAR")) return Forbid();

        var response = await _service.TerminarAsync(evaluacionId, usuario);
        return Ok(response);
    }

    [HttpPost("{evaluacionId:int}/solicitudes-reapertura")]
    public async Task<ActionResult<SolicitarReaperturaResponse>> SolicitarReapertura(
        int evaluacionId,
        [FromBody] SolicitarReaperturaRequest request)
    {
        var usuario = User.Identity?.Name;
        if (string.IsNullOrWhiteSpace(usuario)) return Unauthorized();
        if (!await TienePermisoAsync(usuario, "EVALUACION.SOLICITAR_REAPERTURA")) return Forbid();

        if (string.IsNullOrWhiteSpace(request.Motivo))
            return BadRequest(new { mensaje = "Debe indicar el motivo de la solicitud de reapertura." });

        var response = await _service.SolicitarReaperturaAsync(evaluacionId, request.Motivo.Trim(), usuario);
        return Ok(response);
    }

    [HttpPost("reaperturas/{solicitudReaperturaId:int}/resolver")]
    public async Task<ActionResult<ResolverReaperturaResponse>> ResolverReapertura(
        int solicitudReaperturaId,
        [FromBody] ResolverReaperturaRequest request)
    {
        var usuario = User.Identity?.Name;
        if (string.IsNullOrWhiteSpace(usuario)) return Unauthorized();
        if (!await TienePermisoAsync(usuario, "EVALUACION.AUTORIZAR_REAPERTURA")) return Forbid();

        if (!request.Aprobar && string.IsNullOrWhiteSpace(request.Observacion))
            return BadRequest(new { mensaje = "Debe indicar el motivo del rechazo." });

        var response = await _service.ResolverReaperturaAsync(solicitudReaperturaId, request, usuario);
        return Ok(response);
    }

    [HttpPost("{evaluacionId:int}/cerrar")]
    public async Task<ActionResult<CerrarEvaluacionResponse>> Cerrar(int evaluacionId)
    {
        var usuario = User.Identity?.Name;
        if (string.IsNullOrWhiteSpace(usuario)) return Unauthorized();
        if (!await TienePermisoAsync(usuario, "EVALUACION.CERRAR")) return Forbid();

        var response = await _service.CerrarAsync(evaluacionId, usuario);
        return Ok(response);
    }

    private async Task<bool> TienePermisoAsync(string usuario, string permiso)
    {
        var accesos = await _seguridadService.ObtenerAccesosUsuarioAsync(usuario);
        return accesos?.Permisos.Any(x =>
            string.Equals(x, permiso, StringComparison.OrdinalIgnoreCase)) == true;
    }
}

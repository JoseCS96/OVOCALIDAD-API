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

    [HttpGet("listado")]
    public async Task<ActionResult<List<PanelEvaluacionItemDto>>> ListarEvaluaciones()
    {
        var usuario = User.Identity?.Name;
        if (string.IsNullOrWhiteSpace(usuario)) return Unauthorized();
        if (!await TienePermisoAsync(usuario, "EVALUACION.VER")) return Forbid();
        return Ok(await _service.ListarEvaluacionesAsync(usuario));
    }

    [HttpPost("crear")]
    public async Task<ActionResult<CrearEvaluacionResponse>> Crear([FromBody] CrearEvaluacionRequest request)
    {
        var usuario = User.Identity?.Name;
        if (string.IsNullOrWhiteSpace(usuario)) return Unauthorized();
        if (!await TienePermisoAsync(usuario, "EVALUACION.INICIAR")) return Forbid();
        if (request.LoteId <= 0 || request.TipoEvaluacionId <= 0)
            return BadRequest(new { mensaje = "Lote y tipo de evaluación son obligatorios." });

        var response = await _service.CrearAsync(request, usuario);
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

    [HttpGet("lote/{loteId:int}/ruta")]
    public async Task<ActionResult<RutaEvaluacionLoteDto>> ObtenerRutaLote(int loteId)
    {
        var usuario = User.Identity?.Name;
        if (string.IsNullOrWhiteSpace(usuario)) return Unauthorized();
        if (!await TienePermisoAsync(usuario, "EVALUACION.VER")) return Forbid();
        return Ok(await _service.ObtenerRutaLoteAsync(loteId));
    }

    [HttpGet("{evaluacionId:int}")]
    public async Task<ActionResult<EvaluacionDto>> Obtener(int evaluacionId)
    {
        var usuario = User.Identity?.Name;
        if (string.IsNullOrWhiteSpace(usuario)) return Unauthorized();
        if (!await TienePermisoAsync(usuario, "EVALUACION.VER")) return Forbid();

        var response = await _service.ObtenerAsync(evaluacionId);
        if (response is null) return NotFound();

        var accesos = await _seguridadService.ObtenerAccesosUsuarioAsync(usuario);
        var perfiles = accesos?.Perfiles.Select(p => p.PerfilCodigo).ToHashSet(StringComparer.OrdinalIgnoreCase)
            ?? new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        var supervisor = perfiles.Overlaps(new[] { "ANALISTA_CALIDAD", "JEFE_CALIDAD", "ADMINISTRADOR" });
        if (!supervisor && perfiles.Contains("AUXILIAR_CALIDAD"))
        {
            var propio = string.Equals(response.Cabecera.UsuarioEvaluador, usuario, StringComparison.OrdinalIgnoreCase);
            var disponible = string.Equals(response.Cabecera.EstadoEvaluacion, "PENDIENTE", StringComparison.OrdinalIgnoreCase)
                && string.IsNullOrWhiteSpace(response.Cabecera.UsuarioEvaluador);
            if (!propio && !disponible) return Forbid();
        }
        return Ok(response);
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
    public async Task<ActionResult<CerrarEvaluacionResponse>> Terminar(int evaluacionId)
    {
        var usuario = User.Identity?.Name;
        if (string.IsNullOrWhiteSpace(usuario)) return Unauthorized();
        if (!await TienePermisoAsync(usuario, "EVALUACION.TERMINAR")) return Forbid();

        // En el flujo por etapas, "Terminar" debe consolidar el intento:
        // calcula ResultadoGeneral, mantiene el lote en EVALUACION si corresponde
        // y habilita siguiente etapa o reevaluación.
        var response = await _service.CerrarAsync(evaluacionId, usuario);
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


    [HttpGet("reaperturas")]
    public async Task<ActionResult<List<SolicitudReaperturaItemDto>>> ListarReaperturas(
        [FromQuery] string? estado = null)
    {
        var usuario = User.Identity?.Name;
        if (string.IsNullOrWhiteSpace(usuario)) return Unauthorized();
        if (!await TienePermisoAsync(usuario, "EVALUACION.AUTORIZAR_REAPERTURA")) return Forbid();

        if (!string.IsNullOrWhiteSpace(estado))
        {
            estado = estado.Trim().ToUpperInvariant();
            if (estado is not ("PENDIENTE" or "APROBADA" or "RECHAZADA"))
                return BadRequest(new { mensaje = "Estado de solicitud no válido." });
        }

        var response = await _service.ListarSolicitudesReaperturaAsync(usuario, estado);
        return Ok(response);
    }

    [HttpGet("reaperturas/{solicitudReaperturaId:int}")]
    public async Task<ActionResult<SolicitudReaperturaDetalleDto>> ObtenerReapertura(
        int solicitudReaperturaId)
    {
        var usuario = User.Identity?.Name;
        if (string.IsNullOrWhiteSpace(usuario)) return Unauthorized();
        if (!await TienePermisoAsync(usuario, "EVALUACION.AUTORIZAR_REAPERTURA")) return Forbid();

        var response = await _service.ObtenerSolicitudReaperturaAsync(solicitudReaperturaId, usuario);
        if (response is null) return NotFound();

        if (response.CodigoResultado != 0)
            return NotFound(response);

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


    [HttpGet("pendientes-calculo")]
    public async Task<ActionResult<List<EvaluacionPendienteCalculoDto>>> ListarPendientesCalculo()
    {
        var usuario = User.Identity?.Name;
        if (string.IsNullOrWhiteSpace(usuario)) return Unauthorized();
        if (!await TienePermisoAsync(usuario, "EVALUACION.CONSOLIDAR")) return Forbid();

        return Ok(await _service.ListarPendientesCalculoAsync());
    }

    [HttpPost("precalcular-disposicion")]
    public async Task<ActionResult<PrecalculoEvaluacionesResponse>> PrecalcularDisposicion(
        [FromBody] PrecalculoEvaluacionesRequest request)
    {
        var usuario = User.Identity?.Name;
        if (string.IsNullOrWhiteSpace(usuario)) return Unauthorized();
        if (!await TienePermisoAsync(usuario, "EVALUACION.CONSOLIDAR")) return Forbid();
        if (request.EvaluacionIds.Count == 0)
            return BadRequest(new { mensaje = "Debe seleccionar al menos una evaluación." });

        return Ok(await _service.PrecalcularAsync(request.EvaluacionIds));
    }

    [HttpPost("consolidar")]
    public async Task<ActionResult<List<ConsolidacionEvaluacionResultadoDto>>> Consolidar(
        [FromBody] ConsolidarEvaluacionesRequest request)
    {
        var usuario = User.Identity?.Name;
        if (string.IsNullOrWhiteSpace(usuario)) return Unauthorized();
        if (!await TienePermisoAsync(usuario, "EVALUACION.CONSOLIDAR")) return Forbid();
        if (request.EvaluacionIds.Count == 0)
            return BadRequest(new { mensaje = "Debe seleccionar al menos una evaluación." });

        return Ok(await _service.ConsolidarAsync(request.EvaluacionIds, usuario, request.Observacion));
    }

    private async Task<bool> TienePermisoAsync(string usuario, string permiso)
    {
        var accesos = await _seguridadService.ObtenerAccesosUsuarioAsync(usuario);
        return accesos?.Permisos.Any(x =>
            string.Equals(x, permiso, StringComparison.OrdinalIgnoreCase)) == true;
    }
}

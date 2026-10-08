using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OVOCALIDAD.Application.DTOs.Firmas;
using OVOCALIDAD.Application.Interfaces;
using OVOCALIDAD.Infrastructure.StoredProcedures;

namespace OVOCALIDAD.Api.Controllers.Firmas;

[ApiController]
[Route("api/firmas")]
[Authorize]
public class FirmaController : ControllerBase
{
    private readonly FirmaDocumentoStoredProcedure _firmas;
    private readonly IAuthService _authService;
    private readonly IEspecificacionTecnicaService _etService;

    public FirmaController(
        FirmaDocumentoStoredProcedure firmas,
        IAuthService authService,
        IEspecificacionTecnicaService etService)
    {
        _firmas = firmas;
        _authService = authService;
        _etService = etService;
    }

    [HttpPost("et/{versionId:int}/generar")]
    [Authorize(Policy = "JefeCalidad")]
    public async Task<ActionResult<GenerarSolicitudesFirmaResponse>> GenerarSolicitudesEt(int versionId)
    {
        var detalle = await _etService.ObtenerDetalleAsync(versionId);
        if (detalle is null) return NotFound();

        var estado = detalle.InformacionGeneral.EstadoVersion?.Trim().ToUpperInvariant();
        if (estado is not ("PUBLICADA" or "VIGENTE"))
            return BadRequest(new { mensaje = "Solo se generan solicitudes de firma para ET publicadas o vigentes." });

        var resultado = await _firmas.GenerarSolicitudesEtAsync(
            versionId,
            detalle.Responsables,
            UsuarioSesion());

        return resultado.CodigoResultado == 0
            ? Ok(resultado)
            : BadRequest(resultado);
    }

    // Solicitudes del usuario autenticado.
    [HttpGet("solicitudes")]
    public async Task<ActionResult<IReadOnlyList<FirmaDocumentoSolicitudDto>>> ListarMisSolicitudes([FromQuery] string? estado = null)
    {
        var usuario = UsuarioSesion();
        return Ok(await _firmas.ListarMisSolicitudesAsync(usuario, estado));
    }

    [HttpGet("solicitudes/mia")]
    public async Task<ActionResult<FirmaDocumentoSolicitudDto>> ObtenerMiSolicitud(
        [FromQuery] string tipoDocumento,
        [FromQuery] int entidadId)
    {
        var usuario = UsuarioSesion();
        var solicitud = await _firmas.ObtenerMiSolicitudAsync(usuario, tipoDocumento, entidadId);
        return solicitud is null ? NotFound() : Ok(solicitud);
    }

    // La contraseña se revalida antes de registrar la firma.
    [HttpPost("solicitudes/{solicitudId:long}/firmar")]
    public async Task<ActionResult<OperacionFirmaDocumentoResponse>> Firmar(
        long solicitudId,
        [FromBody] FirmarDocumentoRequest request)
    {
        var usuario = UsuarioSesion();

        if (string.IsNullOrWhiteSpace(request.Password))
            return BadRequest(new { mensaje = "Ingresa tu contraseña para confirmar la firma." });

        var passwordValida = await _authService.ValidarPasswordAsync(usuario, request.Password);

        if (!passwordValida)
            return BadRequest(new { mensaje = "La contraseña ingresada no es correcta." });

        var resultado = await _firmas.FirmarAsync(solicitudId, usuario);

        return resultado.CodigoResultado == 0
            ? Ok(resultado)
            : BadRequest(resultado);
    }

    // Solo devuelve la firma snapshot si realmente fue aplicada a ese documento.
    [HttpGet("documentos/{tipoDocumento}/{entidadId:int}/responsables/{usuarioDni}")]
    public async Task<ActionResult<FirmaDocumentoAplicadaDto>> ObtenerFirmaAplicada(
        string tipoDocumento,
        int entidadId,
        string usuarioDni)
    {
        var firma = await _firmas.ObtenerFirmaAplicadaAsync(tipoDocumento, entidadId, usuarioDni);
        return firma is null ? NotFound() : Ok(firma);
    }

    private string UsuarioSesion()
    {
        var usuario = User.Identity?.Name;
        if (string.IsNullOrWhiteSpace(usuario))
            throw new UnauthorizedAccessException("No se pudo identificar al usuario autenticado.");
        return usuario;
    }
}

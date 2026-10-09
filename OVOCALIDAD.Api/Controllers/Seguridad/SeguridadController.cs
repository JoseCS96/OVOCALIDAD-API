using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OVOCALIDAD.Application.DTOs.Seguridad;
using OVOCALIDAD.Application.Interfaces;

namespace OVOCALIDAD.Api.Controllers.Seguridad;

[ApiController]
[Route("api/seguridad")]
[Authorize]
public class SeguridadController : ControllerBase
{
    private readonly ISeguridadService _service;

    public SeguridadController(ISeguridadService service)
    {
        _service = service;
    }

    [Authorize(Policy = "JefeCalidad")]
    [HttpPost("usuarios")]
    [ProducesResponseType(typeof(CrearUsuarioAccesoResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<CrearUsuarioAccesoResponse>> CrearUsuarioAcceso([FromBody] CrearUsuarioAccesoRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.NombreUsuario))
            return BadRequest(new { mensaje = "El nombre de usuario es obligatorio." });

        if (string.IsNullOrWhiteSpace(request.NombresApellidos))
            return BadRequest(new { mensaje = "Los nombres y apellidos son obligatorios." });

        if (string.IsNullOrWhiteSpace(request.Password) || request.Password.Length < 8)
            return BadRequest(new { mensaje = "La contraseña debe tener al menos 8 caracteres." });

        if (request.PerfilId <= 0)
            return BadRequest(new { mensaje = "El perfil es obligatorio." });

        var usuarioAuditoria = User.Identity?.Name;
        if (string.IsNullOrWhiteSpace(usuarioAuditoria))
            return Unauthorized();

        var response = await _service.CrearUsuarioAccesoAsync(request, usuarioAuditoria);

        return response.CodigoResultado == 0
            ? Ok(response)
            : BadRequest(response);
    }

    [AllowAnonymous]
    [HttpGet("usuarios/{nombreUsuario}/accesos")]
    [ProducesResponseType(typeof(AccesosUsuarioDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<AccesosUsuarioDto>> ObtenerAccesosUsuario(string nombreUsuario)
    {
        var accesos = await _service.ObtenerAccesosUsuarioAsync(nombreUsuario);

        return accesos is null
            ? NotFound(new { mensaje = "Usuario no existe o se encuentra inactivo." })
            : Ok(accesos);
    }

    [HttpGet("mi-acceso")]
    [ProducesResponseType(typeof(AccesosUsuarioDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<AccesosUsuarioDto>> ObtenerMiAcceso()
    {
        var nombreUsuario = User.Identity?.Name;

        if (string.IsNullOrWhiteSpace(nombreUsuario))
            return Unauthorized();

        var accesos = await _service.ObtenerAccesosUsuarioAsync(nombreUsuario);

        return accesos is null
            ? NotFound(new { mensaje = "No se encontraron accesos para el usuario autenticado." })
            : Ok(accesos);
    }
    [HttpGet("notificaciones")]
    public async Task<ActionResult<IReadOnlyList<NotificacionDto>>> ObtenerNotificaciones()
    {
        var nombreUsuario = User.Identity?.Name;
        if (string.IsNullOrWhiteSpace(nombreUsuario)) return Unauthorized();
        return Ok(await _service.ObtenerNotificacionesAsync(nombreUsuario));
    }

    [HttpPut("notificaciones/{notificacionId:long}/leida")]
    public async Task<ActionResult<OperacionNotificacionDto>> MarcarNotificacionLeida(long notificacionId)
    {
        var nombreUsuario = User.Identity?.Name;
        if (string.IsNullOrWhiteSpace(nombreUsuario)) return Unauthorized();
        return Ok(await _service.MarcarNotificacionLeidaAsync(notificacionId, nombreUsuario));
    }

    [HttpPut("notificaciones/modal-mostradas")]
    public async Task<ActionResult<OperacionNotificacionDto>> MarcarModalMostrado()
    {
        var nombreUsuario = User.Identity?.Name;
        if (string.IsNullOrWhiteSpace(nombreUsuario)) return Unauthorized();
        return Ok(await _service.MarcarNotificacionesModalMostradasAsync(nombreUsuario));
    }
}

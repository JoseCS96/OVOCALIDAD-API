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

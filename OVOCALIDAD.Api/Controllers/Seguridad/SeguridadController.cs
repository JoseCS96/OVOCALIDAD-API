using Microsoft.AspNetCore.Mvc;
using OVOCALIDAD.Application.DTOs.Seguridad;
using OVOCALIDAD.Application.Interfaces;

namespace OVOCALIDAD.Api.Controllers.Seguridad;

[ApiController]
[Route("api/seguridad")]
public class SeguridadController : ControllerBase
{
    private readonly ISeguridadService _service;

    public SeguridadController(ISeguridadService service)
    {
        _service = service;
    }

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
}

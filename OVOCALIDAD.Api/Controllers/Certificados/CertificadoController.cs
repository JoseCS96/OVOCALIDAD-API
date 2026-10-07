using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OVOCALIDAD.Application.DTOs.Certificados;
using OVOCALIDAD.Application.Interfaces;

namespace OVOCALIDAD.Api.Controllers.Certificados;

[ApiController]
[Authorize]
[Route("api/certificados")]
public class CertificadoController : ControllerBase
{
    private readonly ICertificadoService _service;
    public CertificadoController(ICertificadoService service) => _service = service;

    [HttpGet("plantillas")]
    public async Task<ActionResult<IReadOnlyList<PlantillaCertificadoListaDto>>> Listar([FromQuery] int? versionFtId, [FromQuery] string? productoCodigo)
        => Ok(await _service.ListarPlantillasAsync(versionFtId, productoCodigo));

    [HttpGet("plantillas/{id:int}")]
    public async Task<ActionResult<PlantillaCertificadoDto>> Obtener(int id)
    {
        var item = await _service.ObtenerPlantillaAsync(id);
        return item is null ? NotFound() : Ok(item);
    }

    [HttpPost("plantillas")]
    public async Task<ActionResult<PlantillaCertificadoOperacionResponse>> Crear([FromBody] CrearPlantillaCertificadoRequest request)
    {
        request.Usuario = UsuarioSesion();
        return Ok(await _service.CrearPlantillaAsync(request));
    }

    [HttpPut("plantillas/{id:int}/diseno")]
    public async Task<ActionResult<PlantillaCertificadoOperacionResponse>> GuardarDiseno(int id, [FromBody] GuardarDisenoPlantillaCertificadoRequest request)
    {
        request.Usuario = UsuarioSesion();
        return Ok(await _service.GuardarDisenoAsync(id, request));
    }

    [HttpDelete("plantillas/{id:int}")]
    public async Task<ActionResult<PlantillaCertificadoOperacionResponse>> Eliminar(int id)
        => Ok(await _service.EliminarPlantillaAsync(id, UsuarioSesion()));

    private string UsuarioSesion()
    {
        var usuario = User.Identity?.Name;
        if (string.IsNullOrWhiteSpace(usuario))
            throw new UnauthorizedAccessException("No se pudo identificar al usuario autenticado.");
        return usuario;
    }
}

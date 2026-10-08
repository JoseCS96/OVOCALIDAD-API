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

    [HttpGet("empresa")]
    public async Task<ActionResult<CertificadoEmpresaDto>> ObtenerEmpresa()
    {
        var item = await _service.ObtenerEmpresaAsync();
        return item is null ? NotFound() : Ok(item);
    }

    [HttpPut("empresa")]
    [Authorize(Policy = "JefeCalidad")]
    public async Task<ActionResult<GuardarCertificadoEmpresaResponse>> GuardarEmpresa([FromBody] GuardarCertificadoEmpresaRequest request)
    {
        request.Usuario = UsuarioSesion();
        return Ok(await _service.GuardarEmpresaAsync(request));
    }

    [HttpGet("plantillas/predeterminada/lote/{loteId:int}")]
    public async Task<ActionResult<PlantillaCertificadoListaDto>> ObtenerPlantillaPredeterminada(int loteId)
    {
        var item = await _service.ObtenerPlantillaPredeterminadaAsync(loteId);
        return item is null ? NotFound() : Ok(item);
    }

    [HttpGet("previsualizar")]
    public async Task<ActionResult<CertificadoVistaDto>> Previsualizar(
        [FromQuery] int loteId,
        [FromQuery] int certificadoPlantillaId)
    {
        var item = await _service.PrevisualizarAsync(loteId, certificadoPlantillaId);
        return item is null ? NotFound() : Ok(item);
    }

    [HttpPost("emitir")]
    public async Task<ActionResult<EmitirCertificadoResponse>> Emitir([FromBody] EmitirCertificadoRequest request)
    {
        var usuario = UsuarioSesion();

        var accesos = HttpContext.RequestServices
            .GetRequiredService<ISeguridadService>();

        var permisos = await accesos.ObtenerAccesosUsuarioAsync(usuario);
        if (permisos?.Permisos.Any(x =>
            string.Equals(x, "CERTIFICADO.EMITIR", StringComparison.OrdinalIgnoreCase)) != true)
            return Forbid();

        return Ok(await _service.EmitirAsync(request, usuario));
    }

    [HttpGet("emitidos/{certificadoId:int}")]
    public async Task<ActionResult<CertificadoVistaDto>> ObtenerEmitido(int certificadoId)
    {
        var item = await _service.ObtenerEmitidoAsync(certificadoId);
        return item is null ? NotFound() : Ok(item);
    }

    private string UsuarioSesion()
    {
        var usuario = User.Identity?.Name;
        if (string.IsNullOrWhiteSpace(usuario))
            throw new UnauthorizedAccessException("No se pudo identificar al usuario autenticado.");
        return usuario;
    }
}

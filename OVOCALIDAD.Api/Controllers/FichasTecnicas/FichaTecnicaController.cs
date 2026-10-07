using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OVOCALIDAD.Application.DTOs.FichasTecnicas;
using OVOCALIDAD.Application.Interfaces;

namespace OVOCALIDAD.Api.Controllers.FichasTecnicas;

[ApiController]
[Authorize]
[Route("api/fichas-tecnicas")]
public class FichaTecnicaController : ControllerBase
{
    private readonly IFichaTecnicaService _service;

    public FichaTecnicaController(IFichaTecnicaService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<FichaTecnicaGestionDto>>> Listar([FromQuery] string? busqueda, [FromQuery] int? estVerId) =>
        Ok(await _service.ListarGestionAsync(busqueda, estVerId));

    [HttpGet("{versionId:int}")]
    public async Task<ActionResult<FichaTecnicaGestionDto>> Obtener(int versionId)
    {
        var item = await _service.ObtenerAsync(versionId);
        return item is null ? NotFound() : Ok(item);
    }

    [HttpGet("para-certificado")]
    public async Task<ActionResult<IReadOnlyList<FichaTecnicaCertificadoDto>>> ListarParaCertificado([FromQuery] string? busqueda) =>
        Ok(await _service.ListarParaCertificadoAsync(busqueda));

    [HttpPost]
    public async Task<ActionResult<CrearFichaTecnicaResponse>> Crear([FromBody] CrearFichaTecnicaRequest request)
    {
        request.Usuario = UsuarioSesion();
        return Ok(await _service.CrearAsync(request));
    }

    [HttpGet("{versionId:int}/caracteristicas")]
    public async Task<ActionResult<IReadOnlyList<FichaTecnicaCaracteristicaDto>>> ListarCaracteristicas(int versionId) =>
        Ok(await _service.ListarCaracteristicasAsync(versionId));

    [HttpPut("{versionId:int}/caracteristicas")]
    public async Task<ActionResult<GuardarCaracteristicaFtResponse>> GuardarCaracteristica(
        int versionId,
        [FromBody] GuardarCaracteristicaFtRequest request)
    {
        request.Usuario = UsuarioSesion();
        return Ok(await _service.GuardarCaracteristicaAsync(versionId, request));
    }

    [HttpDelete("{versionId:int}/caracteristicas/{versionFtCaracteristicaId:int}")]
    public async Task<ActionResult<EliminarCaracteristicaFtResponse>> EliminarCaracteristica(
        int versionId,
        int versionFtCaracteristicaId)
    {
        _ = versionId; // Mantiene una URL consistente y legible por versión.
        return Ok(await _service.EliminarCaracteristicaAsync(versionFtCaracteristicaId, UsuarioSesion()));
    }

    [HttpDelete("{versionId:int}")]
    public async Task<ActionResult<EliminarFichaTecnicaResponse>> EliminarBorrador(int versionId) =>
        Ok(await _service.EliminarBorradorAsync(versionId, UsuarioSesion()));

    [HttpGet("{versionId:int}/configuracion-certificado")]
    public async Task<ActionResult<IReadOnlyList<ConfiguracionCertificadoFtDto>>> ObtenerConfiguracionCertificado(int versionId) =>
        Ok(await _service.ObtenerConfiguracionCertificadoAsync(versionId));

    private string UsuarioSesion()
    {
        var usuario = User.Identity?.Name;
        if (string.IsNullOrWhiteSpace(usuario))
            throw new UnauthorizedAccessException("No se pudo identificar al usuario autenticado.");
        return usuario;
    }
}

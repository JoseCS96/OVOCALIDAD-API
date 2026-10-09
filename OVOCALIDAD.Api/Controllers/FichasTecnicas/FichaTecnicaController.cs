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

    [HttpGet("{versionId:int}/secciones")]
    public async Task<ActionResult<IReadOnlyList<SeccionFtDto>>> ListarSecciones(int versionId) => Ok(await _service.ListarSeccionesAsync(versionId));

    [HttpPost("{versionId:int}/secciones")]
    public async Task<ActionResult<SeccionFtOperacionResponse>> AgregarSeccion(int versionId,[FromBody] AgregarSeccionFtRequest request){request.Usuario=UsuarioSesion();return Ok(await _service.AgregarSeccionAsync(versionId,request));}

    [HttpPut("{versionId:int}/secciones/{versionFtSeccionId:int}/contenido")]
    public async Task<ActionResult<SeccionFtOperacionResponse>> GuardarContenidoSeccion(int versionId,int versionFtSeccionId,[FromBody] GuardarContenidoSeccionFtRequest request){request.Usuario=UsuarioSesion();return Ok(await _service.GuardarContenidoSeccionAsync(versionId,versionFtSeccionId,request));}

    [HttpDelete("{versionId:int}/secciones/{versionFtSeccionId:int}")]
    public async Task<ActionResult<SeccionFtOperacionResponse>> QuitarSeccion(int versionId,int versionFtSeccionId) => Ok(await _service.QuitarSeccionAsync(versionId,versionFtSeccionId,UsuarioSesion()));

    [HttpPut("{versionId:int}/secciones/orden")]
    public async Task<ActionResult<SeccionFtOperacionResponse>> ReordenarSecciones(int versionId,[FromBody] ReordenarSeccionesFtRequest request){request.Usuario=UsuarioSesion();return Ok(await _service.ReordenarSeccionesAsync(versionId,request));}

    [HttpGet("{versionId:int}/configuracion-certificado")]
    public async Task<ActionResult<IReadOnlyList<ConfiguracionCertificadoFtDto>>> ObtenerConfiguracionCertificado(int versionId) =>
        Ok(await _service.ObtenerConfiguracionCertificadoAsync(versionId));

    [HttpPost("{versionId:int}/cambiar-estado")]
    public async Task<ActionResult<CambiarEstadoFtResponse>> CambiarEstado(
        int versionId,
        [FromBody] CambiarEstadoFtRequest request)
    {
        request.Usuario = UsuarioSesion();
        var result = await _service.CambiarEstadoAsync(versionId, request);
        return result.CodigoResultado == 0 ? Ok(result) : BadRequest(result);
    }

    [HttpGet("{versionId:int}/historial-estados")]
    public async Task<ActionResult<IReadOnlyList<HistorialEstadoFtDto>>> HistorialEstados(int versionId) =>
        Ok(await _service.ListarHistorialEstadoAsync(versionId));

    [HttpGet("{versionId:int}/declaraciones")]
    public async Task<ActionResult<IReadOnlyList<DeclaracionFtDto>>> ListarDeclaraciones(int versionId) =>
        Ok(await _service.ListarDeclaracionesAsync(versionId));

    [HttpPut("{versionId:int}/declaraciones")]
    public async Task<ActionResult<OperacionComplementoFtResponse>> GuardarDeclaraciones(
        int versionId,
        [FromBody] GuardarDeclaracionesFtRequest request)
    {
        request.Usuario = UsuarioSesion();
        var result = await _service.GuardarDeclaracionesAsync(versionId, request);
        return result.CodigoResultado == 0 ? Ok(result) : BadRequest(result);
    }

    [HttpGet("{versionId:int}/alergenos")]
    public async Task<ActionResult<IReadOnlyList<AlergenoFtDto>>> ListarAlergenos(int versionId) =>
        Ok(await _service.ListarAlergenosAsync(versionId));

    [HttpPut("{versionId:int}/alergenos")]
    public async Task<ActionResult<OperacionComplementoFtResponse>> GuardarAlergenos(
        int versionId,
        [FromBody] GuardarAlergenosFtRequest request)
    {
        request.Usuario = UsuarioSesion();
        var result = await _service.GuardarAlergenosAsync(versionId, request);
        return result.CodigoResultado == 0 ? Ok(result) : BadRequest(result);
    }

    [HttpGet("{versionId:int}/grupos-caracteristicas")]
    public async Task<ActionResult<IReadOnlyList<GrupoCaracteristicaFtDto>>> ListarGruposCaracteristica(int versionId) =>
        Ok(await _service.ListarGruposCaracteristicaAsync(versionId));

    [HttpPut("{versionId:int}/grupos-caracteristicas/{tipoCaractId:int}")]
    public async Task<ActionResult<OperacionComplementoFtResponse>> GuardarGrupoCaracteristica(
        int versionId,
        int tipoCaractId,
        [FromBody] GuardarGrupoCaracteristicaFtRequest request)
    {
        request.Usuario = UsuarioSesion();
        var result = await _service.GuardarGrupoCaracteristicaAsync(versionId, tipoCaractId, request);
        return result.CodigoResultado == 0 ? Ok(result) : BadRequest(result);
    }

    private string UsuarioSesion()
    {
        var usuario = User.Identity?.Name;
        if (string.IsNullOrWhiteSpace(usuario))
            throw new UnauthorizedAccessException("No se pudo identificar al usuario autenticado.");
        return usuario;
    }
}

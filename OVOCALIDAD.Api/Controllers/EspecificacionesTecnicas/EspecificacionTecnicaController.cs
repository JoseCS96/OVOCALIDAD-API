using Microsoft.AspNetCore.Mvc;
using OVOCALIDAD.Application.DTOs.EspecificacionesTecnicas;
using OVOCALIDAD.Application.Interfaces;

namespace OVOCALIDAD.Api.Controllers.EspecificacionesTecnicas;

[ApiController]
[Route("api/especificaciones-tecnicas")]
public class EspecificacionTecnicaController : ControllerBase
{
    private readonly IEspecificacionTecnicaService _service;

    public EspecificacionTecnicaController(IEspecificacionTecnicaService service)
    {
        _service = service;
    }

    [HttpPost]
    [ProducesResponseType(typeof(CrearEspecificacionTecnicaResponse), StatusCodes.Status200OK)]
    public async Task<ActionResult<CrearEspecificacionTecnicaResponse>> Crear([FromBody] CrearEspecificacionTecnicaRequest request)
    {
        return Ok(await _service.CrearAsync(request));
    }

    [HttpGet("catalogos")]
    [ProducesResponseType(typeof(CatalogosEspecificacionTecnicaDto), StatusCodes.Status200OK)]
    public async Task<ActionResult<CatalogosEspecificacionTecnicaDto>> Catalogos()
    {
        return Ok(await _service.ObtenerCatalogosAsync());
    }

    [HttpGet("secciones")]
    [ProducesResponseType(typeof(SeccionesEtCatalogoDto), StatusCodes.Status200OK)]
    public async Task<ActionResult<SeccionesEtCatalogoDto>> Secciones()
    {
        return Ok(await _service.ObtenerSeccionesAsync());
    }

    [HttpPost("secciones")]
    [ProducesResponseType(typeof(CrearSeccionEtResponse), StatusCodes.Status200OK)]
    public async Task<ActionResult<CrearSeccionEtResponse>> CrearSeccion([FromBody] CrearSeccionEtRequest request)
    {
        return Ok(await _service.CrearSeccionAsync(request));
    }

    [HttpPost("{versionId:int}/secciones")]
    public async Task<ActionResult<AgregarSeccionVersionEtResponse>> AgregarSeccionVersion(
        int versionId,
        [FromBody] AgregarSeccionVersionEtRequest request)
    {
        return Ok(await _service.AgregarSeccionVersionAsync(versionId, request));
    }

    [HttpDelete("{versionId:int}/secciones/{versSeccId:int}")]
    public async Task<ActionResult<QuitarSeccionVersionEtResponse>> QuitarSeccionVersion(
        int versionId,
        int versSeccId,
        [FromBody] QuitarSeccionVersionEtRequest request)
    {
        return Ok(await _service.QuitarSeccionVersionAsync(versionId, versSeccId, request));
    }

    [HttpPut("{versionId:int}/secciones/orden")]
    public async Task<ActionResult<OperacionEstructuraEtResponse>> ReordenarSeccionesVersion(
        int versionId,
        [FromBody] ReordenarSeccionesVersionEtRequest request)
    {
        return Ok(await _service.ReordenarSeccionesVersionAsync(versionId, request));
    }

    [HttpPut("{versionId:int}/secciones/{versSeccId:int}/contenido")]
    public async Task<ActionResult<GuardarContenidoSeccionEtResponse>> GuardarContenidoSeccion(
        int versionId,
        int versSeccId,
        [FromBody] GuardarContenidoSeccionEtRequest request)
    {
        return Ok(await _service.GuardarContenidoSeccionAsync(versionId, versSeccId, request));
    }

    [HttpGet("{versionId:int}/secciones/contenido")]
    public async Task<ActionResult<IReadOnlyList<ContenidoSeccionEtDto>>> ObtenerContenidoSecciones(int versionId)
    {
        return Ok(await _service.ObtenerContenidoSeccionesAsync(versionId));
    }

    [HttpGet("{versionId:int}")]
    [ProducesResponseType(typeof(DetalleEspecificacionTecnicaDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<DetalleEspecificacionTecnicaDto>> ObtenerDetalle(int versionId)
    {
        var detalle = await _service.ObtenerDetalleAsync(versionId);
        return detalle is null ? NotFound() : Ok(detalle);
    }

    [HttpPut("{versionId:int}/informacion-general")]
    public async Task<ActionResult<GuardarInformacionGeneralEtResponse>> GuardarInformacionGeneral(
        int versionId,
        [FromBody] GuardarInformacionGeneralEtRequest request)
    {
        return Ok(await _service.GuardarInformacionGeneralAsync(versionId, request));
    }

    [HttpPut("{versionId:int}/caracteristicas")]
    public async Task<ActionResult<GuardarCaracteristicaEtResponse>> GuardarCaracteristica(
        int versionId,
        [FromBody] GuardarCaracteristicaEtRequest request)
    {
        return Ok(await _service.GuardarCaracteristicaAsync(versionId, request));
    }

    [HttpDelete("{versionId:int}/caracteristicas/{versCaractId:int}")]
    public async Task<ActionResult<EliminarCaracteristicaEtResponse>> EliminarCaracteristica(
        int versionId,
        int versCaractId,
        [FromBody] EliminarCaracteristicaEtRequest request)
    {
        return Ok(await _service.EliminarCaracteristicaAsync(versionId, versCaractId, request));
    }


    [HttpGet]
    [ProducesResponseType(typeof(IReadOnlyList<EspecificacionTecnicaListadoDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IReadOnlyList<EspecificacionTecnicaListadoDto>>> Listar(
        [FromQuery] ListarEspecificacionesTecnicasFiltro filtro)
    {
        return Ok(await _service.ListarAsync(filtro));
    }
}

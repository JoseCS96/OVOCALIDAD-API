using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OVOCALIDAD.Application.DTOs.EspecificacionesTecnicas;
using OVOCALIDAD.Application.Interfaces;

namespace OVOCALIDAD.Api.Controllers.EspecificacionesTecnicas;

[ApiController]
[Route("api/especificaciones-tecnicas")]
[Authorize]
public class EspecificacionTecnicaController : ControllerBase
{
    private readonly IEspecificacionTecnicaService _service;
    private readonly IWebHostEnvironment _environment;
    private readonly IConfiguration _configuration;

    public EspecificacionTecnicaController(
        IEspecificacionTecnicaService service,
        IWebHostEnvironment environment,
        IConfiguration configuration)
    {
        _service = service;
        _environment = environment;
        _configuration = configuration;
    }

    [HttpPost]
    [ProducesResponseType(typeof(CrearEspecificacionTecnicaResponse), StatusCodes.Status200OK)]
    public async Task<ActionResult<CrearEspecificacionTecnicaResponse>> Crear([FromBody] CrearEspecificacionTecnicaRequest request)
    {
        request.Usuario = UsuarioSesion();
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
        request.Usuario = UsuarioSesion();
        return Ok(await _service.CrearSeccionAsync(request));
    }

    [HttpPost("{versionId:int}/secciones")]
    public async Task<ActionResult<AgregarSeccionVersionEtResponse>> AgregarSeccionVersion(
        int versionId,
        [FromBody] AgregarSeccionVersionEtRequest request)
    {
        request.Usuario = UsuarioSesion();
        return Ok(await _service.AgregarSeccionVersionAsync(versionId, request));
    }

    [HttpDelete("{versionId:int}/secciones/{versSeccId:int}")]
    public async Task<ActionResult<QuitarSeccionVersionEtResponse>> QuitarSeccionVersion(
        int versionId,
        int versSeccId,
        [FromBody] QuitarSeccionVersionEtRequest request)
    {
        request.Usuario = UsuarioSesion();
        return Ok(await _service.QuitarSeccionVersionAsync(versionId, versSeccId, request));
    }

    [HttpPut("{versionId:int}/secciones/orden")]
    public async Task<ActionResult<OperacionEstructuraEtResponse>> ReordenarSeccionesVersion(
        int versionId,
        [FromBody] ReordenarSeccionesVersionEtRequest request)
    {
        request.Usuario = UsuarioSesion();
        return Ok(await _service.ReordenarSeccionesVersionAsync(versionId, request));
    }

    [HttpPut("{versionId:int}/secciones/{versSeccId:int}/contenido")]
    public async Task<ActionResult<GuardarContenidoSeccionEtResponse>> GuardarContenidoSeccion(
        int versionId,
        int versSeccId,
        [FromBody] GuardarContenidoSeccionEtRequest request)
    {
        request.Usuario = UsuarioSesion();
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

    [HttpGet("{versionId:int}/pdf")]
    [Produces("application/pdf")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> ObtenerPdf(int versionId)
    {
        var detalle = await _service.ObtenerDetalleAsync(versionId);
        if (detalle is null)
            return NotFound();

        var archivo = detalle.InformacionGeneral;
        if (string.IsNullOrWhiteSpace(archivo.ArchivoOriginalRuta))
            return NotFound(new { mensaje = "La versión no tiene un PDF original vinculado." });

        var rootConfigurado = _configuration["DocumentStorage:RootPath"];
        var rootPath = string.IsNullOrWhiteSpace(rootConfigurado)
            ? Path.Combine(_environment.ContentRootPath, "Documentos")
            : Path.GetFullPath(rootConfigurado);

        var rutaRelativa = archivo.ArchivoOriginalRuta
            .Replace('/', Path.DirectorySeparatorChar)
            .TrimStart(Path.DirectorySeparatorChar);

        var rutaCompleta = Path.GetFullPath(Path.Combine(rootPath, rutaRelativa));
        var rootCompleto = Path.GetFullPath(rootPath).TrimEnd(Path.DirectorySeparatorChar)
            + Path.DirectorySeparatorChar;

        if (!rutaCompleta.StartsWith(rootCompleto, StringComparison.OrdinalIgnoreCase))
            return BadRequest(new { mensaje = "La ruta del documento no es válida." });

        if (!System.IO.File.Exists(rutaCompleta))
            return NotFound(new { mensaje = "El PDF original no se encuentra en el almacenamiento documental." });

        var nombreArchivo = string.IsNullOrWhiteSpace(archivo.ArchivoOriginalNombre)
            ? Path.GetFileName(rutaCompleta)
            : archivo.ArchivoOriginalNombre;

        var nombreSeguro = nombreArchivo.Replace("\"", string.Empty);
        Response.Headers.ContentDisposition = $"inline; filename=\"{nombreSeguro}\"";
        Response.Headers["X-Content-Type-Options"] = "nosniff";

        return new PhysicalFileResult(rutaCompleta, "application/pdf")
        {
            EnableRangeProcessing = true
        };
    }

    [HttpPut("{versionId:int}/informacion-general")]
    public async Task<ActionResult<GuardarInformacionGeneralEtResponse>> GuardarInformacionGeneral(
        int versionId,
        [FromBody] GuardarInformacionGeneralEtRequest request)
    {
        request.Usuario = UsuarioSesion();
        return Ok(await _service.GuardarInformacionGeneralAsync(versionId, request));
    }

    [HttpPut("{versionId:int}/contenido-base")]
    public async Task<ActionResult<GuardarContenidoBaseEtResponse>> GuardarContenidoBase(
        int versionId,
        [FromBody] GuardarContenidoBaseEtRequest request)
    {
        request.Usuario = UsuarioSesion();
        return Ok(await _service.GuardarContenidoBaseAsync(versionId, request));
    }

    [HttpGet("responsables")]
    public async Task<ActionResult<IReadOnlyList<ResponsableEtCatalogoDto>>> Responsables()
    {
        return Ok(await _service.ObtenerResponsablesAsync());
    }

    [HttpPut("{versionId:int}/responsables")]
    public async Task<ActionResult<GuardarResponsablesEtResponse>> GuardarResponsables(
        int versionId,
        [FromBody] GuardarResponsablesEtRequest request)
    {
        request.Usuario = UsuarioSesion();
        return Ok(await _service.GuardarResponsablesAsync(versionId, request));
    }

    [HttpGet("ingredientes/catalogos")]
    public async Task<ActionResult<CatalogosIngredientesEtDto>> CatalogosIngredientes()
    {
        return Ok(await _service.ObtenerCatalogosIngredientesAsync());
    }

    [HttpPut("{versionId:int}/ingredientes")]
    public async Task<ActionResult<GuardarIngredientesEtResponse>> GuardarIngredientes(
        int versionId,
        [FromBody] GuardarIngredientesEtRequest request)
    {
        request.Usuario = UsuarioSesion();
        return Ok(await _service.GuardarIngredientesAsync(versionId, request));
    }

    [HttpPut("{versionId:int}/recetas")]
    public async Task<ActionResult<GuardarRecetasEtResponse>> GuardarRecetas(
        int versionId,
        [FromBody] GuardarRecetasEtRequest request)
    {
        request.Usuario = UsuarioSesion();
        return Ok(await _service.GuardarRecetasAsync(versionId, request));
    }

    [HttpPut("{versionId:int}/procedimientos")]
    public async Task<ActionResult<GuardarProcedimientosEtResponse>> GuardarProcedimientos(
        int versionId,
        [FromBody] GuardarProcedimientosEtRequest request)
    {
        request.Usuario = UsuarioSesion();
        return Ok(await _service.GuardarProcedimientosAsync(versionId, request));
    }

    [HttpGet("tratamientos/catalogos")]
    public async Task<ActionResult<CatalogosTratamientosEtDto>> CatalogosTratamientos()
    {
        return Ok(await _service.ObtenerCatalogosTratamientosAsync());
    }

    [HttpPut("{versionId:int}/tratamientos")]
    public async Task<ActionResult<GuardarTratamientosEtResponse>> GuardarTratamientos(
        int versionId,
        [FromBody] GuardarTratamientosEtRequest request)
    {
        request.Usuario = UsuarioSesion();
        return Ok(await _service.GuardarTratamientosAsync(versionId, request));
    }

    [HttpPut("{versionId:int}/instrucciones")]
    public async Task<ActionResult<GuardarInstruccionesEtResponse>> GuardarInstrucciones(
        int versionId,
        [FromBody] GuardarInstruccionesEtRequest request)
    {
        request.Usuario = UsuarioSesion();
        return Ok(await _service.GuardarInstruccionesAsync(versionId, request));
    }

    [HttpGet("contenido-rotulado/catalogo")]
    public async Task<ActionResult<IReadOnlyList<ContenidoRotuladoCatalogoDto>>> ObtenerCatalogoContenidoRotulado() =>
        Ok(await _service.ObtenerCatalogoContenidoRotuladoAsync());

    [HttpPut("{versionId:int}/contenido-rotulado")]
    public async Task<ActionResult<GuardarContenidoRotuladoEtResponse>> GuardarContenidoRotulado(
        int versionId,
        [FromBody] GuardarContenidoRotuladoEtRequest request)
    {
        request.Usuario = UsuarioSesion();
        return Ok(await _service.GuardarContenidoRotuladoAsync(versionId, request));
    }

    [HttpPut("{versionId:int}/cambios")]
    public async Task<ActionResult<GuardarCambiosEtResponse>> GuardarCambios(
        int versionId,
        [FromBody] GuardarCambiosEtRequest request)
    {
        request.Usuario = UsuarioSesion();
        return Ok(await _service.GuardarCambiosAsync(versionId, request));
    }

    [HttpPut("{versionId:int}/caracteristicas")]
    public async Task<ActionResult<GuardarCaracteristicaEtResponse>> GuardarCaracteristica(
        int versionId,
        [FromBody] GuardarCaracteristicaEtRequest request)
    {
        request.Usuario = UsuarioSesion();
        return Ok(await _service.GuardarCaracteristicaAsync(versionId, request));
    }

    [HttpDelete("{versionId:int}/caracteristicas/{versCaractId:int}")]
    public async Task<ActionResult<EliminarCaracteristicaEtResponse>> EliminarCaracteristica(
        int versionId,
        int versCaractId,
        [FromBody] EliminarCaracteristicaEtRequest request)
    {
        request.Usuario = UsuarioSesion();
        return Ok(await _service.EliminarCaracteristicaAsync(versionId, versCaractId, request));
    }

    [HttpPost("{versionId:int}/cambiar-estado")]
    [ProducesResponseType(typeof(CambiarEstadoVersionEtResponse), StatusCodes.Status200OK)]
    public async Task<ActionResult<CambiarEstadoVersionEtResponse>> CambiarEstado(
        int versionId,
        [FromBody] CambiarEstadoVersionEtRequest request)
    {
        request.Usuario = UsuarioSesion();
        return Ok(await _service.CambiarEstadoAsync(versionId, request));
    }


    [HttpPost("{versionId:int}/resetear")]
    public async Task<ActionResult<OperacionEstructuraEtResponse>> Resetear(int versionId)
    {
        var request = new QuitarSeccionVersionEtRequest { Usuario = UsuarioSesion() };
        return Ok(await _service.ResetearAsync(versionId, request));
    }

    [HttpDelete("{versionId:int}")]
    public async Task<ActionResult<OperacionEstructuraEtResponse>> EliminarBorrador(int versionId)
    {
        var request = new QuitarSeccionVersionEtRequest { Usuario = UsuarioSesion() };
        return Ok(await _service.EliminarBorradorAsync(versionId, request));
    }


    [HttpGet]
    [ProducesResponseType(typeof(IReadOnlyList<EspecificacionTecnicaListadoDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IReadOnlyList<EspecificacionTecnicaListadoDto>>> Listar(
        [FromQuery] ListarEspecificacionesTecnicasFiltro filtro)
    {
        return Ok(await _service.ListarAsync(filtro));
    }

    private string UsuarioSesion()
    {
        var usuario = User.Identity?.Name;
        if (string.IsNullOrWhiteSpace(usuario))
            throw new UnauthorizedAccessException("No se pudo identificar al usuario autenticado.");
        return usuario;
    }
}

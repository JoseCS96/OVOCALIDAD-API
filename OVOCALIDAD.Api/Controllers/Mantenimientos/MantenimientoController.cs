using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OVOCALIDAD.Application.DTOs.Mantenimientos;
using OVOCALIDAD.Infrastructure.StoredProcedures;

namespace OVOCALIDAD.Api.Controllers.Mantenimientos;

[ApiController]
[Route("api/mantenimientos")]
[Authorize(Policy = "JefeCalidad")]
public class MantenimientoController : ControllerBase
{
    private readonly MantenimientoStoredProcedure _storedProcedure;
    public MantenimientoController(MantenimientoStoredProcedure storedProcedure) => _storedProcedure = storedProcedure;

    [HttpGet("ingredientes")]
    public async Task<ActionResult<IReadOnlyList<IngredienteMantenimientoDto>>> ListarIngredientes([FromQuery] IngredienteMantenimientoFiltro filtro) =>
        Ok(await _storedProcedure.ListarIngredientesAsync(filtro));

    [HttpPost("ingredientes")]
    public async Task<ActionResult<GuardarIngredienteResponse>> CrearIngrediente([FromBody] GuardarIngredienteRequest request)
    {
        request.IngredienteId = null;
        request.Usuario = UsuarioSesion();
        return Ok(await _storedProcedure.GuardarIngredienteAsync(request));
    }

    [HttpPut("ingredientes/{ingredienteId:int}")]
    public async Task<ActionResult<GuardarIngredienteResponse>> EditarIngrediente(int ingredienteId, [FromBody] GuardarIngredienteRequest request)
    {
        request.IngredienteId = ingredienteId;
        request.Usuario = UsuarioSesion();
        return Ok(await _storedProcedure.GuardarIngredienteAsync(request));
    }

    [HttpPatch("ingredientes/{ingredienteId:int}/estado")]
    public async Task<ActionResult<CambiarEstadoIngredienteResponse>> CambiarEstadoIngrediente(int ingredienteId, [FromBody] CambiarEstadoIngredienteRequest request)
    {
        request.Usuario = UsuarioSesion();
        return Ok(await _storedProcedure.CambiarEstadoIngredienteAsync(ingredienteId, request));
    }

    [HttpGet("caracteristicas")]
    public async Task<ActionResult<IReadOnlyList<CaracteristicaMantenimientoDto>>> ListarCaracteristicas([FromQuery] CaracteristicaMantenimientoFiltro filtro) =>
        Ok(await _storedProcedure.ListarCaracteristicasAsync(filtro));

    [HttpGet("caracteristicas/catalogos")]
    public async Task<ActionResult<CatalogosCaracteristicaMantenimientoDto>> ObtenerCatalogosCaracteristica() =>
        Ok(await _storedProcedure.ObtenerCatalogosCaracteristicaAsync());

    [HttpPost("caracteristicas")]
    public async Task<ActionResult<GuardarCaracteristicaResponse>> CrearCaracteristica([FromBody] GuardarCaracteristicaRequest request)
    {
        request.CaracteristicaId = null;
        request.Usuario = UsuarioSesion();
        return Ok(await _storedProcedure.GuardarCaracteristicaAsync(request));
    }

    [HttpPut("caracteristicas/{caracteristicaId:int}")]
    public async Task<ActionResult<GuardarCaracteristicaResponse>> EditarCaracteristica(int caracteristicaId, [FromBody] GuardarCaracteristicaRequest request)
    {
        request.CaracteristicaId = caracteristicaId;
        request.Usuario = UsuarioSesion();
        return Ok(await _storedProcedure.GuardarCaracteristicaAsync(request));
    }

    [HttpPatch("caracteristicas/{caracteristicaId:int}/estado")]
    public async Task<ActionResult<CambiarEstadoCaracteristicaResponse>> CambiarEstadoCaracteristica(int caracteristicaId, [FromBody] CambiarEstadoCaracteristicaRequest request)
    {
        request.Usuario = UsuarioSesion();
        return Ok(await _storedProcedure.CambiarEstadoCaracteristicaAsync(caracteristicaId, request));
    }


    [HttpGet("tipos-caracteristica")]
    public async Task<ActionResult<IReadOnlyList<TipoCaracteristicaMantenimientoDetalleDto>>> ListarTiposCaracteristica([FromQuery] TipoCaracteristicaMantenimientoFiltro filtro) =>
        Ok(await _storedProcedure.ListarTiposCaracteristicaAsync(filtro));

    [HttpPost("tipos-caracteristica")]
    public async Task<ActionResult<GuardarTipoCaracteristicaResponse>> CrearTipoCaracteristica([FromBody] GuardarTipoCaracteristicaRequest request)
    {
        request.TipoCaractId = null;
        request.Usuario = UsuarioSesion();
        return Ok(await _storedProcedure.GuardarTipoCaracteristicaAsync(request));
    }

    [HttpPut("tipos-caracteristica/{tipoCaractId:int}")]
    public async Task<ActionResult<GuardarTipoCaracteristicaResponse>> EditarTipoCaracteristica(int tipoCaractId, [FromBody] GuardarTipoCaracteristicaRequest request)
    {
        request.TipoCaractId = tipoCaractId;
        request.Usuario = UsuarioSesion();
        return Ok(await _storedProcedure.GuardarTipoCaracteristicaAsync(request));
    }

    [HttpPatch("tipos-caracteristica/{tipoCaractId:int}/estado")]
    public async Task<ActionResult<CambiarEstadoTipoCaracteristicaResponse>> CambiarEstadoTipoCaracteristica(int tipoCaractId, [FromBody] CambiarEstadoTipoCaracteristicaRequest request)
    {
        request.Usuario = UsuarioSesion();
        return Ok(await _storedProcedure.CambiarEstadoTipoCaracteristicaAsync(tipoCaractId, request));
    }

    [HttpGet("metodos-ensayo")]
    public async Task<ActionResult<IReadOnlyList<MetodoEnsayoMantenimientoDetalleDto>>> ListarMetodosEnsayo([FromQuery] MetodoEnsayoMantenimientoFiltro filtro) =>
        Ok(await _storedProcedure.ListarMetodosEnsayoAsync(filtro));

    [HttpPost("metodos-ensayo")]
    public async Task<ActionResult<GuardarMetodoEnsayoResponse>> CrearMetodoEnsayo([FromBody] GuardarMetodoEnsayoRequest request)
    {
        request.MetEnsayoId = null;
        request.Usuario = UsuarioSesion();
        return Ok(await _storedProcedure.GuardarMetodoEnsayoAsync(request));
    }

    [HttpPut("metodos-ensayo/{metEnsayoId:int}")]
    public async Task<ActionResult<GuardarMetodoEnsayoResponse>> EditarMetodoEnsayo(int metEnsayoId, [FromBody] GuardarMetodoEnsayoRequest request)
    {
        request.MetEnsayoId = metEnsayoId;
        request.Usuario = UsuarioSesion();
        return Ok(await _storedProcedure.GuardarMetodoEnsayoAsync(request));
    }

    [HttpPatch("metodos-ensayo/{metEnsayoId:int}/estado")]
    public async Task<ActionResult<CambiarEstadoMetodoEnsayoResponse>> CambiarEstadoMetodoEnsayo(int metEnsayoId, [FromBody] CambiarEstadoMetodoEnsayoRequest request)
    {
        request.Usuario = UsuarioSesion();
        return Ok(await _storedProcedure.CambiarEstadoMetodoEnsayoAsync(metEnsayoId, request));
    }


    [HttpGet("contenidos-rotulado")]
    public async Task<ActionResult<IReadOnlyList<ContenidoRotuladoMantenimientoDto>>> ListarContenidosRotulado([FromQuery] ContenidoRotuladoMantenimientoFiltro filtro) =>
        Ok(await _storedProcedure.ListarContenidosRotuladoAsync(filtro));

    [HttpPost("contenidos-rotulado")]
    public async Task<ActionResult<GuardarContenidoRotuladoResponse>> CrearContenidoRotulado([FromBody] GuardarContenidoRotuladoRequest request)
    {
        request.ContRotuladoId = null;
        request.Usuario = UsuarioSesion();
        return Ok(await _storedProcedure.GuardarContenidoRotuladoAsync(request));
    }

    [HttpPut("contenidos-rotulado/{contRotuladoId:int}")]
    public async Task<ActionResult<GuardarContenidoRotuladoResponse>> EditarContenidoRotulado(int contRotuladoId, [FromBody] GuardarContenidoRotuladoRequest request)
    {
        request.ContRotuladoId = contRotuladoId;
        request.Usuario = UsuarioSesion();
        return Ok(await _storedProcedure.GuardarContenidoRotuladoAsync(request));
    }

    [HttpPatch("contenidos-rotulado/{contRotuladoId:int}/estado")]
    public async Task<ActionResult<CambiarEstadoContenidoRotuladoResponse>> CambiarEstadoContenidoRotulado(int contRotuladoId, [FromBody] CambiarEstadoContenidoRotuladoRequest request)
    {
        request.Usuario = UsuarioSesion();
        return Ok(await _storedProcedure.CambiarEstadoContenidoRotuladoAsync(contRotuladoId, request));
    }


    [HttpGet("cargos")]
    public async Task<ActionResult<IReadOnlyList<CargoMantenimientoDto>>> ListarCargos([FromQuery] CargoMantenimientoFiltro filtro) =>
        Ok(await _storedProcedure.ListarCargosAsync(filtro));

    [HttpGet("cargos/activos")]
    public async Task<ActionResult<IReadOnlyList<CargoActivoDto>>> ObtenerCargosActivos() =>
        Ok(await _storedProcedure.ObtenerCargosActivosAsync());

    [HttpPost("cargos")]
    public async Task<ActionResult<GuardarCargoResponse>> CrearCargo([FromBody] GuardarCargoRequest request)
    {
        request.CargoId = null;
        request.Usuario = UsuarioSesion();
        return Ok(await _storedProcedure.GuardarCargoAsync(request));
    }

    [HttpPut("cargos/{cargoId:int}")]
    public async Task<ActionResult<GuardarCargoResponse>> EditarCargo(int cargoId, [FromBody] GuardarCargoRequest request)
    {
        request.CargoId = cargoId;
        request.Usuario = UsuarioSesion();
        return Ok(await _storedProcedure.GuardarCargoAsync(request));
    }

    [HttpPatch("cargos/{cargoId:int}/estado")]
    public async Task<ActionResult<CambiarEstadoCargoResponse>> CambiarEstadoCargo(int cargoId, [FromBody] CambiarEstadoCargoRequest request)
    {
        request.Usuario = UsuarioSesion();
        return Ok(await _storedProcedure.CambiarEstadoCargoAsync(cargoId, request));
    }

    [HttpDelete("cargos/{cargoId:int}")]
    public async Task<ActionResult<GuardarCargoResponse>> EliminarCargo(int cargoId) =>
        Ok(await _storedProcedure.EliminarCargoAsync(cargoId, UsuarioSesion()));

    [HttpGet("responsables")]
    public async Task<ActionResult<IReadOnlyList<ResponsableMantenimientoDto>>> ListarResponsables([FromQuery] ResponsableMantenimientoFiltro filtro) =>
        Ok(await _storedProcedure.ListarResponsablesAsync(filtro));

    [HttpPost("responsables")]
    public async Task<ActionResult<CrearResponsableResponse>> CrearResponsable([FromBody] CrearResponsableRequest request)
    {
        request.Usuario = UsuarioSesion();
        return Ok(await _storedProcedure.CrearResponsableAsync(request));
    }

    [HttpPut("responsables/{usuarioDni}")]
    public async Task<ActionResult<OperacionResponsableResponse>> EditarResponsable(string usuarioDni, [FromBody] EditarResponsableRequest request)
    {
        request.Usuario = UsuarioSesion();
        return Ok(await _storedProcedure.EditarResponsableAsync(usuarioDni, request));
    }

    [HttpPut("responsables/{usuarioDni}/cargo")]
    public async Task<ActionResult<CambiarCargoResponsableResponse>> CambiarCargoResponsable(string usuarioDni, [FromBody] CambiarCargoResponsableRequest request)
    {
        request.Usuario = UsuarioSesion();
        return Ok(await _storedProcedure.CambiarCargoResponsableAsync(usuarioDni, request));
    }

    [HttpGet("responsables/{usuarioDni}/historial-cargos")]
    public async Task<ActionResult<IReadOnlyList<HistorialCargoResponsableDto>>> ObtenerHistorialCargosResponsable(string usuarioDni) =>
        Ok(await _storedProcedure.ObtenerHistorialCargosResponsableAsync(usuarioDni));

    [HttpPatch("responsables/{usuarioDni}/estado")]
    public async Task<ActionResult<CambiarEstadoResponsableResponse>> CambiarEstadoResponsable(string usuarioDni, [FromBody] CambiarEstadoResponsableRequest request)
    {
        request.Usuario = UsuarioSesion();
        return Ok(await _storedProcedure.CambiarEstadoResponsableAsync(usuarioDni, request));
    }

    [HttpDelete("responsables/{usuarioDni}")]
    public async Task<ActionResult<OperacionResponsableResponse>> EliminarResponsable(string usuarioDni) =>
        Ok(await _storedProcedure.EliminarResponsableAsync(usuarioDni, UsuarioSesion()));

    [HttpGet("responsables/{usuarioDni}/firma")]
    public async Task<ActionResult<FirmaResponsableDto>> ObtenerFirmaResponsable(string usuarioDni)
    {
        var firma = await _storedProcedure.ObtenerFirmaResponsableAsync(usuarioDni);
        return firma is null ? NotFound() : Ok(firma);
    }

    [HttpPut("responsables/{usuarioDni}/firma")]
    [RequestSizeLimit(2_500_000)]
    public async Task<ActionResult<OperacionFirmaResponsableResponse>> GuardarFirmaResponsable(string usuarioDni, IFormFile firma)
    {
        if (firma is null || firma.Length == 0)
            return BadRequest("Selecciona una imagen de firma.");

        var permitidos = new[] { "image/png", "image/jpeg", "image/webp" };
        if (!permitidos.Contains(firma.ContentType, StringComparer.OrdinalIgnoreCase))
            return BadRequest("La firma debe ser una imagen PNG, JPG/JPEG o WEBP.");

        if (firma.Length > 2_000_000)
            return BadRequest("La imagen de firma no debe superar 2 MB.");

        await using var ms = new MemoryStream();
        await firma.CopyToAsync(ms);

        var request = new GuardarFirmaResponsableRequest
        {
            UsuarioDni = usuarioDni,
            FirmaImagen = ms.ToArray(),
            FirmaMimeType = firma.ContentType,
            FirmaNombreArchivo = Path.GetFileName(firma.FileName),
            Usuario = UsuarioSesion()
        };

        return Ok(await _storedProcedure.GuardarFirmaResponsableAsync(request));
    }

    [HttpDelete("responsables/{usuarioDni}/firma")]
    public async Task<ActionResult<OperacionFirmaResponsableResponse>> EliminarFirmaResponsable(string usuarioDni) =>
        Ok(await _storedProcedure.EliminarFirmaResponsableAsync(usuarioDni, UsuarioSesion()));

    [HttpGet("responsables/{usuarioDni}/usuario-acceso")]
    public async Task<ActionResult<VinculoResponsableUsuarioDto>> ObtenerVinculoResponsableUsuario(string usuarioDni)
    {
        var vinculo = await _storedProcedure.ObtenerVinculoResponsableUsuarioAsync(usuarioDni);
        return vinculo is null
            ? Ok(new VinculoResponsableUsuarioDto { UsuarioDni = usuarioDni })
            : Ok(vinculo);
    }

    [HttpPut("responsables/{usuarioDni}/usuario-acceso")]
    public async Task<ActionResult<VincularResponsableUsuarioResponse>> VincularResponsableUsuario(
        string usuarioDni,
        [FromBody] VincularResponsableUsuarioRequest request)
    {
        request.Usuario = UsuarioSesion();
        return Ok(await _storedProcedure.VincularResponsableUsuarioAsync(usuarioDni, request));
    }

    [HttpPost("responsables/{usuarioDni}/historial-cargos")]
    public async Task<ActionResult<GuardarCargoHistoricoResponsableResponse>> AgregarCargoHistoricoResponsable(string usuarioDni, [FromBody] GuardarCargoHistoricoResponsableRequest request)
    {
        request.Usuario = UsuarioSesion();
        return Ok(await _storedProcedure.AgregarCargoHistoricoResponsableAsync(usuarioDni, request));
    }

    [HttpPut("responsables/historial-cargos/{usuarioCargoHistorialId:int}")]
    public async Task<ActionResult<GuardarCargoHistoricoResponsableResponse>> EditarCargoHistoricoResponsable(int usuarioCargoHistorialId, [FromBody] GuardarCargoHistoricoResponsableRequest request)
    {
        request.Usuario = UsuarioSesion();
        return Ok(await _storedProcedure.EditarCargoHistoricoResponsableAsync(usuarioCargoHistorialId, request));
    }


    [HttpGet("fases")]
    public async Task<ActionResult<IReadOnlyList<FaseMantenimientoDto>>> ListarFases([FromQuery] string? buscar = null, [FromQuery] bool incluirInactivos = true) =>
        Ok(await _storedProcedure.ListarFasesAsync(buscar, incluirInactivos));

    [HttpPost("fases")]
    public async Task<ActionResult<FaseMantenimientoDto>> CrearFase([FromBody] GuardarFaseRequest request)
    {
        if (!int.TryParse(UsuarioSesion(), out var usuario)) return BadRequest("El usuario autenticado debe tener identificador numérico para auditar FASE.");
        if (string.IsNullOrWhiteSpace(request.Codigo) || request.Codigo.Length > 20 ||
            string.IsNullOrWhiteSpace(request.Descripcion) || request.Descripcion.Length > 150)
            return BadRequest("Código (máx. 20) y descripción (máx. 150) son obligatorios.");
        request.FaseId = null;
        request.Usuario = usuario;
        return Ok(await _storedProcedure.GuardarFaseAsync(request));
    }

    [HttpPut("fases/{faseId:int}")]
    public async Task<ActionResult<FaseMantenimientoDto>> EditarFase(int faseId, [FromBody] GuardarFaseRequest request)
    {
        if (!int.TryParse(UsuarioSesion(), out var usuario)) return BadRequest("El usuario autenticado debe tener identificador numérico para auditar FASE.");
        if (string.IsNullOrWhiteSpace(request.Codigo) || request.Codigo.Length > 20 ||
            string.IsNullOrWhiteSpace(request.Descripcion) || request.Descripcion.Length > 150)
            return BadRequest("Código (máx. 20) y descripción (máx. 150) son obligatorios.");
        request.FaseId = faseId;
        request.Usuario = usuario;
        return Ok(await _storedProcedure.GuardarFaseAsync(request));
    }

    [HttpPatch("fases/{faseId:int}/estado")]
    public async Task<ActionResult<FaseMantenimientoDto>> CambiarEstadoFase(int faseId, [FromBody] CambiarEstadoFaseRequest request)
    {
        if (!int.TryParse(UsuarioSesion(), out var usuario)) return BadRequest("El usuario autenticado debe tener identificador numérico para auditar FASE.");
        if (request.Estado is not ("ACTIVO" or "INACTIVO")) return BadRequest("Estado inválido.");
        request.Usuario = usuario;
        return Ok(await _storedProcedure.CambiarEstadoFaseAsync(faseId, request));
    }

    private string UsuarioSesion()
    {
        var usuario = User.Identity?.Name;
        if (string.IsNullOrWhiteSpace(usuario))
            throw new UnauthorizedAccessException("No se pudo identificar al usuario autenticado.");
        return usuario;
    }
}

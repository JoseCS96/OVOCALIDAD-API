using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OVOCALIDAD.Application.DTOs.Mantenimientos;
using OVOCALIDAD.Infrastructure.StoredProcedures;

namespace OVOCALIDAD.Api.Controllers.Mantenimientos;

[ApiController]
[Route("api/mantenimientos")]
[Authorize]
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

    private string UsuarioSesion()
    {
        var usuario = User.Identity?.Name;
        if (string.IsNullOrWhiteSpace(usuario))
            throw new UnauthorizedAccessException("No se pudo identificar al usuario autenticado.");
        return usuario;
    }
}

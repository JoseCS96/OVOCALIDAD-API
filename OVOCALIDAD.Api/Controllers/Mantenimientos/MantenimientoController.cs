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

    private string UsuarioSesion()
    {
        var usuario = User.Identity?.Name;
        if (string.IsNullOrWhiteSpace(usuario))
            throw new UnauthorizedAccessException("No se pudo identificar al usuario autenticado.");
        return usuario;
    }
}

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

    private string UsuarioSesion()
    {
        var usuario = User.Identity?.Name;
        if (string.IsNullOrWhiteSpace(usuario))
            throw new UnauthorizedAccessException("No se pudo identificar al usuario autenticado.");
        return usuario;
    }
}

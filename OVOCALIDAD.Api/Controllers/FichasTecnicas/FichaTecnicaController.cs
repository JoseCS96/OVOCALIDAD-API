using Microsoft.AspNetCore.Mvc;
using OVOCALIDAD.Application.DTOs.FichasTecnicas;
using OVOCALIDAD.Application.Interfaces;

namespace OVOCALIDAD.Api.Controllers.FichasTecnicas;

[ApiController]
[Route("api/fichas-tecnicas")]
public class FichaTecnicaController : ControllerBase
{
    private readonly IFichaTecnicaService _service;
    public FichaTecnicaController(IFichaTecnicaService service) => _service = service;

    [HttpGet("{versionId:int}/secciones")]
    public async Task<ActionResult<IReadOnlyList<SeccionFichaTecnicaDto>>> ListarSecciones(int versionId) => Ok(await _service.ListarSeccionesAsync(versionId));

    [HttpPut("{versionId:int}/secciones/{seccionId:int}")]
    public async Task<ActionResult<OperacionFichaTecnicaResponse>> GuardarSeccion(int versionId, int seccionId, [FromBody] GuardarSeccionFichaTecnicaRequest request) =>
        Ok(await _service.GuardarSeccionAsync(versionId, seccionId, request));

    [HttpPost("{versionId:int}/secciones")]
    public async Task<ActionResult<OperacionFichaTecnicaResponse>> AgregarSeccion(int versionId, [FromBody] AgregarSeccionFichaTecnicaRequest request) =>
        Ok(await _service.AgregarSeccionAsync(versionId, request));

    [HttpDelete("{versionId:int}/secciones/{seccionId:int}")]
    public async Task<ActionResult<OperacionFichaTecnicaResponse>> QuitarSeccion(int versionId, int seccionId, [FromBody] QuitarSeccionFichaTecnicaRequest request) =>
        Ok(await _service.QuitarSeccionAsync(versionId, seccionId, request));

    [HttpPut("{versionId:int}/secciones/orden")]
    public async Task<ActionResult<OperacionFichaTecnicaResponse>> ReordenarSecciones(int versionId, [FromBody] ReordenarSeccionesFichaTecnicaRequest request) =>
        Ok(await _service.ReordenarSeccionesAsync(versionId, request));

    [HttpGet("{versionId:int}/caracteristicas")]
    public async Task<ActionResult<IReadOnlyList<CaracteristicaFichaTecnicaDto>>> ListarCaracteristicas(int versionId) =>
        Ok(await _service.ListarCaracteristicasAsync(versionId));

    [HttpPut("{versionId:int}/caracteristicas/{caracteristicaId:int}")]
    public async Task<ActionResult<OperacionFichaTecnicaResponse>> GuardarCaracteristica(int versionId, int caracteristicaId, [FromBody] GuardarCaracteristicaFichaTecnicaRequest request) =>
        Ok(await _service.GuardarCaracteristicaAsync(versionId, caracteristicaId, request));
}

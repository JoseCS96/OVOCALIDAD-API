using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OVOCALIDAD.Application.DTOs.Mantenimientos;
using OVOCALIDAD.Infrastructure.StoredProcedures;

namespace OVOCALIDAD.Api.Controllers.Firmas;

[ApiController]
[Route("api/firmas")]
[Authorize]
public class FirmaController : ControllerBase
{
    private readonly MantenimientoStoredProcedure _storedProcedure;

    public FirmaController(MantenimientoStoredProcedure storedProcedure)
    {
        _storedProcedure = storedProcedure;
    }

    [HttpGet("responsables/{usuarioDni}")]
    public async Task<ActionResult<FirmaResponsableDto>> ObtenerFirmaResponsable(string usuarioDni)
    {
        var firma = await _storedProcedure.ObtenerFirmaResponsableAsync(usuarioDni);
        return firma is null ? NotFound() : Ok(firma);
    }
}

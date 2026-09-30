using Microsoft.AspNetCore.Authorization;
using OVOCALIDAD.Application.Interfaces;

namespace OVOCALIDAD.Api.Security;

public sealed class PerfilRequirement : IAuthorizationRequirement
{
    public PerfilRequirement(string perfilCodigo) => PerfilCodigo = perfilCodigo;
    public string PerfilCodigo { get; }
}

public sealed class PerfilAuthorizationHandler : AuthorizationHandler<PerfilRequirement>
{
    private readonly ISeguridadService _seguridadService;

    public PerfilAuthorizationHandler(ISeguridadService seguridadService)
    {
        _seguridadService = seguridadService;
    }

    protected override async Task HandleRequirementAsync(
        AuthorizationHandlerContext context,
        PerfilRequirement requirement)
    {
        var nombreUsuario = context.User.Identity?.Name;
        if (string.IsNullOrWhiteSpace(nombreUsuario))
            return;

        var acceso = await _seguridadService.ObtenerAccesosUsuarioAsync(nombreUsuario);
        if (acceso?.Perfiles.Any(p =>
            string.Equals(p.PerfilCodigo, requirement.PerfilCodigo, StringComparison.OrdinalIgnoreCase)) == true)
        {
            context.Succeed(requirement);
        }
    }
}

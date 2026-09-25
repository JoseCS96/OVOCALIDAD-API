using OVOCALIDAD.Application.DTOs.Seguridad;
using OVOCALIDAD.Application.Interfaces;
using OVOCALIDAD.Infrastructure.StoredProcedures;

namespace OVOCALIDAD.Infrastructure.Repositories;

public class SeguridadRepository : ISeguridadRepository
{
    private readonly SeguridadStoredProcedure _storedProcedure;

    public SeguridadRepository(SeguridadStoredProcedure storedProcedure)
    {
        _storedProcedure = storedProcedure;
    }

    public Task<AccesosUsuarioDto?> ObtenerAccesosUsuarioAsync(string nombreUsuario) =>
        _storedProcedure.ObtenerAccesosUsuarioAsync(nombreUsuario);
}

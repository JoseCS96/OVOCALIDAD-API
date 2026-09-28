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
    public Task<IReadOnlyList<NotificacionDto>> ObtenerNotificacionesAsync(string nombreUsuario) =>
        _storedProcedure.ObtenerNotificacionesAsync(nombreUsuario);

    public Task<OperacionNotificacionDto> MarcarNotificacionLeidaAsync(long notificacionId, string nombreUsuario) =>
        _storedProcedure.MarcarNotificacionLeidaAsync(notificacionId, nombreUsuario);

    public Task<OperacionNotificacionDto> MarcarNotificacionesModalMostradasAsync(string nombreUsuario) =>
        _storedProcedure.MarcarNotificacionesModalMostradasAsync(nombreUsuario);
}

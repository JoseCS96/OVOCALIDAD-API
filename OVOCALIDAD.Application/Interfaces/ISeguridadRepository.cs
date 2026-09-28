using OVOCALIDAD.Application.DTOs.Seguridad;

namespace OVOCALIDAD.Application.Interfaces;

public interface ISeguridadRepository
{
    Task<AccesosUsuarioDto?> ObtenerAccesosUsuarioAsync(string nombreUsuario);
    Task<IReadOnlyList<NotificacionDto>> ObtenerNotificacionesAsync(string nombreUsuario);
    Task<OperacionNotificacionDto> MarcarNotificacionLeidaAsync(long notificacionId, string nombreUsuario);
    Task<OperacionNotificacionDto> MarcarNotificacionesModalMostradasAsync(string nombreUsuario);
}

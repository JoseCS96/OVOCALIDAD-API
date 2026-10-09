using OVOCALIDAD.Application.DTOs.Seguridad;

namespace OVOCALIDAD.Application.Interfaces;

public interface ISeguridadRepository
{
    Task<AccesosUsuarioDto?> ObtenerAccesosUsuarioAsync(string nombreUsuario);
    Task<CrearUsuarioAccesoResponse> CrearUsuarioAccesoAsync(CrearUsuarioAccesoDbRequest request);
    Task<IReadOnlyList<UsuarioAccesoMantenimientoDto>> ListarUsuariosAccesoAsync(string? busqueda, bool? estado);
    Task<IReadOnlyList<PerfilAccesoMantenimientoDto>> ListarPerfilesAccesoAsync();
    Task<CambiarEstadoUsuarioAccesoResponse> CambiarEstadoUsuarioAccesoAsync(int segUsuarioId, bool estado, string usuarioAuditoria);
    Task<IReadOnlyList<NotificacionDto>> ObtenerNotificacionesAsync(string nombreUsuario);
    Task<OperacionNotificacionDto> MarcarNotificacionLeidaAsync(long notificacionId, string nombreUsuario);
    Task<OperacionNotificacionDto> MarcarNotificacionesModalMostradasAsync(string nombreUsuario);
}

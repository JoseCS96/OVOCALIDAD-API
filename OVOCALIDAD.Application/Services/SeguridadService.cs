using OVOCALIDAD.Application.DTOs.Seguridad;
using OVOCALIDAD.Application.Interfaces;

namespace OVOCALIDAD.Application.Services;

public class SeguridadService : ISeguridadService
{
    private readonly ISeguridadRepository _repository;
    private readonly IPasswordService _passwordService;

    public SeguridadService(ISeguridadRepository repository, IPasswordService passwordService)
    {
        _repository = repository;
        _passwordService = passwordService;
    }

    public Task<AccesosUsuarioDto?> ObtenerAccesosUsuarioAsync(string nombreUsuario) =>
        _repository.ObtenerAccesosUsuarioAsync(nombreUsuario);

    public Task<CrearUsuarioAccesoResponse> CrearUsuarioAccesoAsync(CrearUsuarioAccesoRequest request, string usuarioAuditoria)
    {
        var dbRequest = new CrearUsuarioAccesoDbRequest
        {
            NombreUsuario = request.NombreUsuario.Trim(),
            NombresApellidos = request.NombresApellidos.Trim(),
            Correo = string.IsNullOrWhiteSpace(request.Correo) ? null : request.Correo.Trim(),
            PasswordHash = _passwordService.Hash(request.Password),
            PerfilId = request.PerfilId,
            UsuarioAuditoria = usuarioAuditoria
        };

        return _repository.CrearUsuarioAccesoAsync(dbRequest);
    }

    public Task<IReadOnlyList<UsuarioAccesoMantenimientoDto>> ListarUsuariosAccesoAsync(string? busqueda, bool? estado) =>
        _repository.ListarUsuariosAccesoAsync(busqueda, estado);

    public Task<IReadOnlyList<PerfilAccesoMantenimientoDto>> ListarPerfilesAccesoAsync() =>
        _repository.ListarPerfilesAccesoAsync();

    public Task<CambiarEstadoUsuarioAccesoResponse> CambiarEstadoUsuarioAccesoAsync(int segUsuarioId, bool estado, string usuarioAuditoria) =>
        _repository.CambiarEstadoUsuarioAccesoAsync(segUsuarioId, estado, usuarioAuditoria);

    public Task<IReadOnlyList<NotificacionDto>> ObtenerNotificacionesAsync(string nombreUsuario) =>
        _repository.ObtenerNotificacionesAsync(nombreUsuario);

    public Task<OperacionNotificacionDto> MarcarNotificacionLeidaAsync(long notificacionId, string nombreUsuario) =>
        _repository.MarcarNotificacionLeidaAsync(notificacionId, nombreUsuario);

    public Task<OperacionNotificacionDto> MarcarNotificacionesModalMostradasAsync(string nombreUsuario) =>
        _repository.MarcarNotificacionesModalMostradasAsync(nombreUsuario);
}

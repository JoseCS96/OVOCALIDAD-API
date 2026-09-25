using OVOCALIDAD.Application.DTOs.Seguridad;

namespace OVOCALIDAD.Application.Interfaces;

public interface ISeguridadService
{
    Task<AccesosUsuarioDto?> ObtenerAccesosUsuarioAsync(string nombreUsuario);
}

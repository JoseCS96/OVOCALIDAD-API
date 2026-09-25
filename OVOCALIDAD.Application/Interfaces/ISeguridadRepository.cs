using OVOCALIDAD.Application.DTOs.Seguridad;

namespace OVOCALIDAD.Application.Interfaces;

public interface ISeguridadRepository
{
    Task<AccesosUsuarioDto?> ObtenerAccesosUsuarioAsync(string nombreUsuario);
}

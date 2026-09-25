using OVOCALIDAD.Application.DTOs.Seguridad;
using OVOCALIDAD.Application.Interfaces;

namespace OVOCALIDAD.Application.Services;

public class SeguridadService : ISeguridadService
{
    private readonly ISeguridadRepository _repository;

    public SeguridadService(ISeguridadRepository repository)
    {
        _repository = repository;
    }

    public Task<AccesosUsuarioDto?> ObtenerAccesosUsuarioAsync(string nombreUsuario) =>
        _repository.ObtenerAccesosUsuarioAsync(nombreUsuario);
}

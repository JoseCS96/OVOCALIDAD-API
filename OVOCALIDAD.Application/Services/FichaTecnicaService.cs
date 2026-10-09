using OVOCALIDAD.Application.DTOs.FichasTecnicas;
using OVOCALIDAD.Application.Interfaces;

namespace OVOCALIDAD.Application.Services;

public class FichaTecnicaService : IFichaTecnicaService
{
    private readonly IFichaTecnicaRepository _repository;

    public FichaTecnicaService(IFichaTecnicaRepository repository)
    {
        _repository = repository;
    }

    public Task<IReadOnlyList<FichaTecnicaGestionDto>> ListarGestionAsync(string? busqueda, int? estVerId) =>
        _repository.ListarGestionAsync(busqueda, estVerId);

    public Task<FichaTecnicaGestionDto?> ObtenerAsync(int versionId) =>
        _repository.ObtenerAsync(versionId);

    public Task<IReadOnlyList<FichaTecnicaCertificadoDto>> ListarParaCertificadoAsync(string? busqueda) =>
        _repository.ListarParaCertificadoAsync(busqueda);

    public Task<CrearFichaTecnicaResponse> CrearAsync(CrearFichaTecnicaRequest request) =>
        _repository.CrearAsync(request);

    public Task<IReadOnlyList<FichaTecnicaCaracteristicaDto>> ListarCaracteristicasAsync(int versionId) =>
        _repository.ListarCaracteristicasAsync(versionId);

    public Task<GuardarCaracteristicaFtResponse> GuardarCaracteristicaAsync(int versionId, GuardarCaracteristicaFtRequest request) =>
        _repository.GuardarCaracteristicaAsync(versionId, request);

    public Task<EliminarCaracteristicaFtResponse> EliminarCaracteristicaAsync(int versionFtCaracteristicaId, string usuario) =>
        _repository.EliminarCaracteristicaAsync(versionFtCaracteristicaId, usuario);

    public Task<IReadOnlyList<ConfiguracionCertificadoFtDto>> ObtenerConfiguracionCertificadoAsync(int versionId) =>
        _repository.ObtenerConfiguracionCertificadoAsync(versionId);

    public Task<EliminarFichaTecnicaResponse> EliminarBorradorAsync(int versionId, string usuario) =>
        _repository.EliminarBorradorAsync(versionId, usuario);

    public Task<IReadOnlyList<SeccionFtDto>> ListarSeccionesAsync(int versionId) => _repository.ListarSeccionesAsync(versionId);
    public Task<SeccionFtOperacionResponse> GuardarContenidoSeccionAsync(int versionId, int versSeccId, GuardarContenidoSeccionFtRequest request) => _repository.GuardarContenidoSeccionAsync(versionId, versSeccId, request);
    public Task<SeccionFtOperacionResponse> AgregarSeccionAsync(int versionId, AgregarSeccionFtRequest request) => _repository.AgregarSeccionAsync(versionId, request);
    public Task<SeccionFtOperacionResponse> QuitarSeccionAsync(int versionId, int versSeccId, string usuario) => _repository.QuitarSeccionAsync(versionId, versSeccId, usuario);
    public Task<SeccionFtOperacionResponse> ReordenarSeccionesAsync(int versionId, ReordenarSeccionesFtRequest request) => _repository.ReordenarSeccionesAsync(versionId, request);
    public Task<CambiarEstadoFtResponse> CambiarEstadoAsync(int versionId, CambiarEstadoFtRequest request) => _repository.CambiarEstadoAsync(versionId, request);
    public Task<IReadOnlyList<HistorialEstadoFtDto>> ListarHistorialEstadoAsync(int versionId) => _repository.ListarHistorialEstadoAsync(versionId);

    public Task<IReadOnlyList<DeclaracionFtDto>> ListarDeclaracionesAsync(int versionId) =>
        _repository.ListarDeclaracionesAsync(versionId);

    public Task<OperacionComplementoFtResponse> GuardarDeclaracionesAsync(int versionId, GuardarDeclaracionesFtRequest request) =>
        _repository.GuardarDeclaracionesAsync(versionId, request);

    public Task<IReadOnlyList<AlergenoFtDto>> ListarAlergenosAsync(int versionId) =>
        _repository.ListarAlergenosAsync(versionId);

    public Task<OperacionComplementoFtResponse> GuardarAlergenosAsync(int versionId, GuardarAlergenosFtRequest request) =>
        _repository.GuardarAlergenosAsync(versionId, request);

    public Task<IReadOnlyList<GrupoCaracteristicaFtDto>> ListarGruposCaracteristicaAsync(int versionId) =>
        _repository.ListarGruposCaracteristicaAsync(versionId);

    public Task<OperacionComplementoFtResponse> GuardarGrupoCaracteristicaAsync(int versionId, int tipoCaractId, GuardarGrupoCaracteristicaFtRequest request) =>
        _repository.GuardarGrupoCaracteristicaAsync(versionId, tipoCaractId, request);
}

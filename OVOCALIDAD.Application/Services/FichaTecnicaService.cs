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
}

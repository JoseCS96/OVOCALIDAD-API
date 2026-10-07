using OVOCALIDAD.Application.DTOs.FichasTecnicas;
using OVOCALIDAD.Application.Interfaces;

namespace OVOCALIDAD.Application.Services;

public class FichaTecnicaService : IFichaTecnicaService
{
    private readonly IFichaTecnicaRepository _repository;
    public FichaTecnicaService(IFichaTecnicaRepository repository) => _repository = repository;

    public Task<IReadOnlyList<SeccionFichaTecnicaDto>> ListarSeccionesAsync(int versionId) => _repository.ListarSeccionesAsync(versionId);
    public Task<OperacionFichaTecnicaResponse> GuardarSeccionAsync(int versionId, int seccionId, GuardarSeccionFichaTecnicaRequest request) => _repository.GuardarSeccionAsync(versionId, seccionId, request);
    public Task<OperacionFichaTecnicaResponse> AgregarSeccionAsync(int versionId, AgregarSeccionFichaTecnicaRequest request) => _repository.AgregarSeccionAsync(versionId, request);
    public Task<OperacionFichaTecnicaResponse> QuitarSeccionAsync(int versionId, int seccionId, QuitarSeccionFichaTecnicaRequest request) => _repository.QuitarSeccionAsync(versionId, seccionId, request);
    public Task<OperacionFichaTecnicaResponse> ReordenarSeccionesAsync(int versionId, ReordenarSeccionesFichaTecnicaRequest request) => _repository.ReordenarSeccionesAsync(versionId, request);
    public Task<IReadOnlyList<CaracteristicaFichaTecnicaDto>> ListarCaracteristicasAsync(int versionId) => _repository.ListarCaracteristicasAsync(versionId);
    public Task<OperacionFichaTecnicaResponse> GuardarCaracteristicaAsync(int versionId, int caracteristicaId, GuardarCaracteristicaFichaTecnicaRequest request) => _repository.GuardarCaracteristicaAsync(versionId, caracteristicaId, request);
}

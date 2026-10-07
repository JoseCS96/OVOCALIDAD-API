using OVOCALIDAD.Application.DTOs.FichasTecnicas;
using OVOCALIDAD.Application.Interfaces;
using OVOCALIDAD.Infrastructure.StoredProcedures;

namespace OVOCALIDAD.Infrastructure.Repositories;

public class FichaTecnicaRepository : IFichaTecnicaRepository
{
    private readonly FichaTecnicaStoredProcedure _storedProcedure;
    public FichaTecnicaRepository(FichaTecnicaStoredProcedure storedProcedure) => _storedProcedure = storedProcedure;

    public Task<IReadOnlyList<SeccionFichaTecnicaDto>> ListarSeccionesAsync(int versionId) => _storedProcedure.ListarSeccionesAsync(versionId);
    public Task<OperacionFichaTecnicaResponse> GuardarSeccionAsync(int versionId, int seccionId, GuardarSeccionFichaTecnicaRequest request) => _storedProcedure.GuardarSeccionAsync(versionId, seccionId, request);
    public Task<OperacionFichaTecnicaResponse> AgregarSeccionAsync(int versionId, AgregarSeccionFichaTecnicaRequest request) => _storedProcedure.AgregarSeccionAsync(versionId, request);
    public Task<OperacionFichaTecnicaResponse> QuitarSeccionAsync(int versionId, int seccionId, QuitarSeccionFichaTecnicaRequest request) => _storedProcedure.QuitarSeccionAsync(versionId, seccionId, request);
    public Task<OperacionFichaTecnicaResponse> ReordenarSeccionesAsync(int versionId, ReordenarSeccionesFichaTecnicaRequest request) => _storedProcedure.ReordenarSeccionesAsync(versionId, request);
    public Task<IReadOnlyList<CaracteristicaFichaTecnicaDto>> ListarCaracteristicasAsync(int versionId) => _storedProcedure.ListarCaracteristicasAsync(versionId);
    public Task<OperacionFichaTecnicaResponse> GuardarCaracteristicaAsync(int versionId, int caracteristicaId, GuardarCaracteristicaFichaTecnicaRequest request) => _storedProcedure.GuardarCaracteristicaAsync(versionId, caracteristicaId, request);
}

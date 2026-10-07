using OVOCALIDAD.Application.DTOs.FichasTecnicas;

namespace OVOCALIDAD.Application.Interfaces;

public interface IFichaTecnicaService
{
    Task<IReadOnlyList<SeccionFichaTecnicaDto>> ListarSeccionesAsync(int versionId);
    Task<OperacionFichaTecnicaResponse> GuardarSeccionAsync(int versionId, int seccionId, GuardarSeccionFichaTecnicaRequest request);
    Task<OperacionFichaTecnicaResponse> AgregarSeccionAsync(int versionId, AgregarSeccionFichaTecnicaRequest request);
    Task<OperacionFichaTecnicaResponse> QuitarSeccionAsync(int versionId, int seccionId, QuitarSeccionFichaTecnicaRequest request);
    Task<OperacionFichaTecnicaResponse> ReordenarSeccionesAsync(int versionId, ReordenarSeccionesFichaTecnicaRequest request);
    Task<IReadOnlyList<CaracteristicaFichaTecnicaDto>> ListarCaracteristicasAsync(int versionId);
    Task<OperacionFichaTecnicaResponse> GuardarCaracteristicaAsync(int versionId, int caracteristicaId, GuardarCaracteristicaFichaTecnicaRequest request);
}

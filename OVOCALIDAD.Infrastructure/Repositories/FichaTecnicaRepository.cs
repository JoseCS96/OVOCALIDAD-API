using OVOCALIDAD.Application.DTOs.FichasTecnicas;
using OVOCALIDAD.Application.Interfaces;
using OVOCALIDAD.Infrastructure.StoredProcedures;

namespace OVOCALIDAD.Infrastructure.Repositories;

public class FichaTecnicaRepository : IFichaTecnicaRepository
{
    private readonly FichaTecnicaStoredProcedure _storedProcedure;

    public FichaTecnicaRepository(FichaTecnicaStoredProcedure storedProcedure)
    {
        _storedProcedure = storedProcedure;
    }

    public Task<IReadOnlyList<FichaTecnicaCaracteristicaDto>> ListarCaracteristicasAsync(int versionId) =>
        _storedProcedure.ListarCaracteristicasAsync(versionId);

    public Task<GuardarCaracteristicaFtResponse> GuardarCaracteristicaAsync(int versionId, GuardarCaracteristicaFtRequest request) =>
        _storedProcedure.GuardarCaracteristicaAsync(versionId, request);

    public Task<EliminarCaracteristicaFtResponse> EliminarCaracteristicaAsync(int versionFtCaracteristicaId, string usuario) =>
        _storedProcedure.EliminarCaracteristicaAsync(versionFtCaracteristicaId, usuario);

    public Task<IReadOnlyList<ConfiguracionCertificadoFtDto>> ObtenerConfiguracionCertificadoAsync(int versionId) =>
        _storedProcedure.ObtenerConfiguracionCertificadoAsync(versionId);
}

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

    public Task<IReadOnlyList<FichaTecnicaGestionDto>> ListarGestionAsync(string? busqueda, int? estVerId) =>
        _storedProcedure.ListarGestionAsync(busqueda, estVerId);

    public Task<FichaTecnicaGestionDto?> ObtenerAsync(int versionId) =>
        _storedProcedure.ObtenerAsync(versionId);

    public Task<IReadOnlyList<FichaTecnicaCertificadoDto>> ListarParaCertificadoAsync(string? busqueda) =>
        _storedProcedure.ListarParaCertificadoAsync(busqueda);

    public Task<CrearFichaTecnicaResponse> CrearAsync(CrearFichaTecnicaRequest request) =>
        _storedProcedure.CrearAsync(request);

    public Task<IReadOnlyList<FichaTecnicaCaracteristicaDto>> ListarCaracteristicasAsync(int versionId) =>
        _storedProcedure.ListarCaracteristicasAsync(versionId);

    public Task<GuardarCaracteristicaFtResponse> GuardarCaracteristicaAsync(int versionId, GuardarCaracteristicaFtRequest request) =>
        _storedProcedure.GuardarCaracteristicaAsync(versionId, request);

    public Task<EliminarCaracteristicaFtResponse> EliminarCaracteristicaAsync(int versionFtCaracteristicaId, string usuario) =>
        _storedProcedure.EliminarCaracteristicaAsync(versionFtCaracteristicaId, usuario);

    public Task<IReadOnlyList<ConfiguracionCertificadoFtDto>> ObtenerConfiguracionCertificadoAsync(int versionId) =>
        _storedProcedure.ObtenerConfiguracionCertificadoAsync(versionId);
}

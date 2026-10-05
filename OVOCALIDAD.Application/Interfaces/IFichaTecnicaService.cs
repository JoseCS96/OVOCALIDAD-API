using OVOCALIDAD.Application.DTOs.FichasTecnicas;

namespace OVOCALIDAD.Application.Interfaces;

public interface IFichaTecnicaService
{
    Task<IReadOnlyList<FichaTecnicaCaracteristicaDto>> ListarCaracteristicasAsync(int versionId);
    Task<GuardarCaracteristicaFtResponse> GuardarCaracteristicaAsync(int versionId, GuardarCaracteristicaFtRequest request);
    Task<EliminarCaracteristicaFtResponse> EliminarCaracteristicaAsync(int versionFtCaracteristicaId, string usuario);
    Task<IReadOnlyList<ConfiguracionCertificadoFtDto>> ObtenerConfiguracionCertificadoAsync(int versionId);
}

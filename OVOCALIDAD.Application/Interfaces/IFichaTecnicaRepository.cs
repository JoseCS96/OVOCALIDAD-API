using OVOCALIDAD.Application.DTOs.FichasTecnicas;

namespace OVOCALIDAD.Application.Interfaces;

public interface IFichaTecnicaRepository
{
    Task<IReadOnlyList<FichaTecnicaGestionDto>> ListarGestionAsync(string? busqueda, int? estVerId);
    Task<FichaTecnicaGestionDto?> ObtenerAsync(int versionId);
    Task<IReadOnlyList<FichaTecnicaCertificadoDto>> ListarParaCertificadoAsync(string? busqueda);
    Task<CrearFichaTecnicaResponse> CrearAsync(CrearFichaTecnicaRequest request);
    Task<IReadOnlyList<FichaTecnicaCaracteristicaDto>> ListarCaracteristicasAsync(int versionId);
    Task<GuardarCaracteristicaFtResponse> GuardarCaracteristicaAsync(int versionId, GuardarCaracteristicaFtRequest request);
    Task<EliminarCaracteristicaFtResponse> EliminarCaracteristicaAsync(int versionFtCaracteristicaId, string usuario);
    Task<IReadOnlyList<ConfiguracionCertificadoFtDto>> ObtenerConfiguracionCertificadoAsync(int versionId);
    Task<EliminarFichaTecnicaResponse> EliminarBorradorAsync(int versionId, string usuario);
    Task<IReadOnlyList<SeccionFtDto>> ListarSeccionesAsync(int versionId);
    Task<SeccionFtOperacionResponse> GuardarContenidoSeccionAsync(int versionId, int versSeccId, GuardarContenidoSeccionFtRequest request);
    Task<SeccionFtOperacionResponse> AgregarSeccionAsync(int versionId, AgregarSeccionFtRequest request);
    Task<SeccionFtOperacionResponse> QuitarSeccionAsync(int versionId, int versSeccId, string usuario);
    Task<SeccionFtOperacionResponse> ReordenarSeccionesAsync(int versionId, ReordenarSeccionesFtRequest request);
}

using OVOCALIDAD.Application.DTOs.EspecificacionesTecnicas;

namespace OVOCALIDAD.Application.Interfaces;

public interface IEspecificacionTecnicaRepository
{
    Task<CrearEspecificacionTecnicaResponse> CrearAsync(CrearEspecificacionTecnicaRequest request);
    Task<CatalogosEspecificacionTecnicaDto> ObtenerCatalogosAsync();
    Task<SeccionesEtCatalogoDto> ObtenerSeccionesAsync();
    Task<CrearSeccionEtResponse> CrearSeccionAsync(CrearSeccionEtRequest request);
    Task<AgregarSeccionVersionEtResponse> AgregarSeccionVersionAsync(int versionId, AgregarSeccionVersionEtRequest request);
    Task<QuitarSeccionVersionEtResponse> QuitarSeccionVersionAsync(int versionId, int versSeccId, QuitarSeccionVersionEtRequest request);
    Task<OperacionEstructuraEtResponse> ReordenarSeccionesVersionAsync(int versionId, ReordenarSeccionesVersionEtRequest request);
    Task<GuardarContenidoSeccionEtResponse> GuardarContenidoSeccionAsync(int versionId, int versSeccId, GuardarContenidoSeccionEtRequest request);
    Task<IReadOnlyList<ContenidoSeccionEtDto>> ObtenerContenidoSeccionesAsync(int versionId);
    Task<DetalleEspecificacionTecnicaDto?> ObtenerDetalleAsync(int versionId);
    Task<GuardarInformacionGeneralEtResponse> GuardarInformacionGeneralAsync(int versionId, GuardarInformacionGeneralEtRequest request);
    Task<GuardarCaracteristicaEtResponse> GuardarCaracteristicaAsync(int versionId, GuardarCaracteristicaEtRequest request);
    Task<EliminarCaracteristicaEtResponse> EliminarCaracteristicaAsync(int versionId, int versCaractId, EliminarCaracteristicaEtRequest request);
    Task<IReadOnlyList<EspecificacionTecnicaListadoDto>> ListarAsync(ListarEspecificacionesTecnicasFiltro filtro);
    Task<CambiarEstadoVersionEtResponse> CambiarEstadoAsync(int versionId, CambiarEstadoVersionEtRequest request);
}

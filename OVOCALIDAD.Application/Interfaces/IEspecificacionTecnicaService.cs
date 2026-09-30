using OVOCALIDAD.Application.DTOs.EspecificacionesTecnicas;

namespace OVOCALIDAD.Application.Interfaces;

public interface IEspecificacionTecnicaService
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
    Task<IReadOnlyList<VersionReemplazableEtDto>> ObtenerVersionesReemplazablesAsync(int versionId);
    Task<GuardarInformacionGeneralEtResponse> GuardarInformacionGeneralAsync(int versionId, GuardarInformacionGeneralEtRequest request);
    Task<GuardarContenidoBaseEtResponse> GuardarContenidoBaseAsync(int versionId, GuardarContenidoBaseEtRequest request);
    Task<IReadOnlyList<ResponsableEtCatalogoDto>> ObtenerResponsablesAsync();
    Task<GuardarResponsablesEtResponse> GuardarResponsablesAsync(int versionId, GuardarResponsablesEtRequest request);
    Task<CatalogosIngredientesEtDto> ObtenerCatalogosIngredientesAsync();
    Task<GuardarIngredientesEtResponse> GuardarIngredientesAsync(int versionId, GuardarIngredientesEtRequest request);
    Task<GuardarRecetasEtResponse> GuardarRecetasAsync(int versionId, GuardarRecetasEtRequest request);
    Task<GuardarProcedimientosEtResponse> GuardarProcedimientosAsync(int versionId, GuardarProcedimientosEtRequest request);
    Task<CatalogosTratamientosEtDto> ObtenerCatalogosTratamientosAsync();
    Task<GuardarTratamientosEtResponse> GuardarTratamientosAsync(int versionId, GuardarTratamientosEtRequest request);
    Task<GuardarInstruccionesEtResponse> GuardarInstruccionesAsync(int versionId, GuardarInstruccionesEtRequest request);
    Task<IReadOnlyList<ContenidoRotuladoCatalogoDto>> ObtenerCatalogoContenidoRotuladoAsync();
    Task<GuardarContenidoRotuladoEtResponse> GuardarContenidoRotuladoAsync(int versionId, GuardarContenidoRotuladoEtRequest request);
    Task<GuardarCambiosEtResponse> GuardarCambiosAsync(int versionId, GuardarCambiosEtRequest request);
    Task<GuardarAnexosEtResponse> GuardarAnexosAsync(int versionId, GuardarAnexosEtRequest request);
    Task<GuardarCaracteristicaEtResponse> GuardarCaracteristicaAsync(int versionId, GuardarCaracteristicaEtRequest request);
    Task<EliminarCaracteristicaEtResponse> EliminarCaracteristicaAsync(int versionId, int versCaractId, EliminarCaracteristicaEtRequest request);
    Task<IReadOnlyList<EspecificacionTecnicaListadoDto>> ListarAsync(ListarEspecificacionesTecnicasFiltro filtro);
    Task<CambiarEstadoVersionEtResponse> CambiarEstadoAsync(int versionId, CambiarEstadoVersionEtRequest request);
    Task<OperacionEstructuraEtResponse> ResetearAsync(int versionId, QuitarSeccionVersionEtRequest request);
    Task<OperacionEstructuraEtResponse> EliminarBorradorAsync(int versionId, QuitarSeccionVersionEtRequest request);
}

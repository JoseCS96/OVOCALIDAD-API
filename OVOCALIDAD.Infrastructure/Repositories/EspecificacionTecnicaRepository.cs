using OVOCALIDAD.Application.DTOs.EspecificacionesTecnicas;
using OVOCALIDAD.Application.Interfaces;
using OVOCALIDAD.Infrastructure.StoredProcedures;

namespace OVOCALIDAD.Infrastructure.Repositories;

public class EspecificacionTecnicaRepository : IEspecificacionTecnicaRepository
{
    private readonly EspecificacionTecnicaStoredProcedure _storedProcedure;

    public EspecificacionTecnicaRepository(EspecificacionTecnicaStoredProcedure storedProcedure)
    {
        _storedProcedure = storedProcedure;
    }

    public Task<CrearEspecificacionTecnicaResponse> CrearAsync(CrearEspecificacionTecnicaRequest request) =>
        _storedProcedure.CrearAsync(request);

    public Task<CatalogosEspecificacionTecnicaDto> ObtenerCatalogosAsync() =>
        _storedProcedure.ObtenerCatalogosAsync();

    public Task<SeccionesEtCatalogoDto> ObtenerSeccionesAsync() =>
        _storedProcedure.ObtenerSeccionesAsync();

    public Task<CrearSeccionEtResponse> CrearSeccionAsync(CrearSeccionEtRequest request) =>
        _storedProcedure.CrearSeccionAsync(request);

    public Task<AgregarSeccionVersionEtResponse> AgregarSeccionVersionAsync(int versionId, AgregarSeccionVersionEtRequest request) =>
        _storedProcedure.AgregarSeccionVersionAsync(versionId, request);

    public Task<QuitarSeccionVersionEtResponse> QuitarSeccionVersionAsync(int versionId, int versSeccId, QuitarSeccionVersionEtRequest request) =>
        _storedProcedure.QuitarSeccionVersionAsync(versionId, versSeccId, request);

    public Task<OperacionEstructuraEtResponse> ReordenarSeccionesVersionAsync(int versionId, ReordenarSeccionesVersionEtRequest request) =>
        _storedProcedure.ReordenarSeccionesVersionAsync(versionId, request);

    public Task<GuardarContenidoSeccionEtResponse> GuardarContenidoSeccionAsync(int versionId, int versSeccId, GuardarContenidoSeccionEtRequest request) =>
        _storedProcedure.GuardarContenidoSeccionAsync(versionId, versSeccId, request);

    public Task<IReadOnlyList<ContenidoSeccionEtDto>> ObtenerContenidoSeccionesAsync(int versionId) =>
        _storedProcedure.ObtenerContenidoSeccionesAsync(versionId);

    public Task<DetalleEspecificacionTecnicaDto?> ObtenerDetalleAsync(int versionId) =>
        _storedProcedure.ObtenerDetalleAsync(versionId);
    public Task<GuardarInformacionGeneralEtResponse> GuardarInformacionGeneralAsync(int versionId, GuardarInformacionGeneralEtRequest request) =>
        _storedProcedure.GuardarInformacionGeneralAsync(versionId, request);

    public Task<GuardarCaracteristicaEtResponse> GuardarCaracteristicaAsync(int versionId, GuardarCaracteristicaEtRequest request) =>
        _storedProcedure.GuardarCaracteristicaAsync(versionId, request);

    public Task<EliminarCaracteristicaEtResponse> EliminarCaracteristicaAsync(int versionId, int versCaractId, EliminarCaracteristicaEtRequest request) =>
        _storedProcedure.EliminarCaracteristicaAsync(versionId, versCaractId, request);

    public Task<IReadOnlyList<EspecificacionTecnicaListadoDto>> ListarAsync(ListarEspecificacionesTecnicasFiltro filtro) => _storedProcedure.ListarAsync(filtro);

    public Task<CambiarEstadoVersionEtResponse> CambiarEstadoAsync(int versionId, CambiarEstadoVersionEtRequest request) =>
        _storedProcedure.CambiarEstadoAsync(versionId, request);
}

using OVOCALIDAD.Application.DTOs.EspecificacionesTecnicas;
using OVOCALIDAD.Application.Interfaces;

namespace OVOCALIDAD.Application.Services;

public class EspecificacionTecnicaService : IEspecificacionTecnicaService
{
    private readonly IEspecificacionTecnicaRepository _repository;

    public EspecificacionTecnicaService(IEspecificacionTecnicaRepository repository)
    {
        _repository = repository;
    }

    public Task<CrearEspecificacionTecnicaResponse> CrearAsync(CrearEspecificacionTecnicaRequest request) =>
        _repository.CrearAsync(request);

    public Task<CatalogosEspecificacionTecnicaDto> ObtenerCatalogosAsync() =>
        _repository.ObtenerCatalogosAsync();

    public Task<SeccionesEtCatalogoDto> ObtenerSeccionesAsync() =>
        _repository.ObtenerSeccionesAsync();

    public Task<CrearSeccionEtResponse> CrearSeccionAsync(CrearSeccionEtRequest request) =>
        _repository.CrearSeccionAsync(request);

    public Task<AgregarSeccionVersionEtResponse> AgregarSeccionVersionAsync(int versionId, AgregarSeccionVersionEtRequest request) =>
        _repository.AgregarSeccionVersionAsync(versionId, request);

    public Task<QuitarSeccionVersionEtResponse> QuitarSeccionVersionAsync(int versionId, int versSeccId, QuitarSeccionVersionEtRequest request) =>
        _repository.QuitarSeccionVersionAsync(versionId, versSeccId, request);

    public Task<OperacionEstructuraEtResponse> ReordenarSeccionesVersionAsync(int versionId, ReordenarSeccionesVersionEtRequest request) =>
        _repository.ReordenarSeccionesVersionAsync(versionId, request);

    public Task<GuardarContenidoSeccionEtResponse> GuardarContenidoSeccionAsync(int versionId, int versSeccId, GuardarContenidoSeccionEtRequest request) =>
        _repository.GuardarContenidoSeccionAsync(versionId, versSeccId, request);

    public Task<DetalleEspecificacionTecnicaDto?> ObtenerDetalleAsync(int versionId) =>
        _repository.ObtenerDetalleAsync(versionId);
    public Task<GuardarInformacionGeneralEtResponse> GuardarInformacionGeneralAsync(int versionId, GuardarInformacionGeneralEtRequest request) =>
        _repository.GuardarInformacionGeneralAsync(versionId, request);

    public Task<GuardarCaracteristicaEtResponse> GuardarCaracteristicaAsync(int versionId, GuardarCaracteristicaEtRequest request) =>
        _repository.GuardarCaracteristicaAsync(versionId, request);

    public Task<EliminarCaracteristicaEtResponse> EliminarCaracteristicaAsync(int versionId, int versCaractId, EliminarCaracteristicaEtRequest request) =>
        _repository.EliminarCaracteristicaAsync(versionId, versCaractId, request);

    public Task<IReadOnlyList<EspecificacionTecnicaListadoDto>> ListarAsync(ListarEspecificacionesTecnicasFiltro filtro) => _repository.ListarAsync(filtro);
}

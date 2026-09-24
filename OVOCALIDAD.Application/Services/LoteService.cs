using OVOCALIDAD.Application.DTOs.Lotes;
using OVOCALIDAD.Application.Interfaces;

namespace OVOCALIDAD.Application.Services;

public class LoteService : ILoteService
{
    private readonly ILoteRepository _loteRepository;

    public LoteService(ILoteRepository loteRepository) => _loteRepository = loteRepository;

    public Task<GenerarLoteResponse> GenerarLoteAsync(GenerarLoteRequest request) =>
        _loteRepository.GenerarLoteAsync(request);

    public Task<IReadOnlyList<LoteListadoDto>> ListarLotesAsync(ListarLotesFiltro filtro) =>
        _loteRepository.ListarLotesAsync(filtro);

    public Task<CatalogosLoteDto> ObtenerCatalogosAsync() =>
        _loteRepository.ObtenerCatalogosAsync();
}

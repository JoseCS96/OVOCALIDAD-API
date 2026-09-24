using OVOCALIDAD.Application.DTOs.Lotes;
using OVOCALIDAD.Application.Interfaces;

namespace OVOCALIDAD.Application.Services;

public class LoteService : ILoteService
{
    private readonly ILoteRepository _loteRepository;

    public LoteService(ILoteRepository loteRepository)
    {
        _loteRepository = loteRepository;
    }

    public async Task<GenerarLoteResponse> GenerarLoteAsync(
        GenerarLoteRequest request)
    {
        return await _loteRepository.GenerarLoteAsync(request);
    }

    public async Task<IReadOnlyList<LoteListadoDto>> ListarLotesAsync(
        ListarLotesFiltro filtro)
    {
        return await _loteRepository.ListarLotesAsync(filtro);
    }
}

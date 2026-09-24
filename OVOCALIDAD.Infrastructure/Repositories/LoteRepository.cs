using OVOCALIDAD.Application.DTOs.Lotes;
using OVOCALIDAD.Application.Interfaces;
using OVOCALIDAD.Infrastructure.StoredProcedures;

namespace OVOCALIDAD.Infrastructure.Repositories;

public class LoteRepository : ILoteRepository
{
    private readonly LoteStoredProcedure _storedProcedure;

    public LoteRepository(LoteStoredProcedure storedProcedure) => _storedProcedure = storedProcedure;

    public Task<GenerarLoteResponse> GenerarLoteAsync(GenerarLoteRequest request) =>
        _storedProcedure.GenerarLoteAsync(request);

    public Task<IReadOnlyList<LoteListadoDto>> ListarLotesAsync(ListarLotesFiltro filtro) =>
        _storedProcedure.ListarLotesAsync(filtro);

    public Task<CatalogosLoteDto> ObtenerCatalogosAsync() =>
        _storedProcedure.ObtenerCatalogosAsync();
}

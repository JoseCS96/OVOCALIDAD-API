using OVOCALIDAD.Application.DTOs.Lotes;
using OVOCALIDAD.Application.Interfaces;
using OVOCALIDAD.Infrastructure.StoredProcedures;

namespace OVOCALIDAD.Infrastructure.Repositories;

public class LoteRepository : ILoteRepository
{
    private readonly LoteStoredProcedure _storedProcedure;

    public LoteRepository(LoteStoredProcedure storedProcedure)
    {
        _storedProcedure = storedProcedure;
    }

    public async Task<GenerarLoteResponse> GenerarLoteAsync(
        GenerarLoteRequest request)
    {
        return await _storedProcedure.GenerarLoteAsync(request);
    }
}
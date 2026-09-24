using OVOCALIDAD.Application.DTOs.Lotes;

namespace OVOCALIDAD.Application.Interfaces;

public interface ILoteRepository
{
    Task<GenerarLoteResponse> GenerarLoteAsync(
        GenerarLoteRequest request);
}
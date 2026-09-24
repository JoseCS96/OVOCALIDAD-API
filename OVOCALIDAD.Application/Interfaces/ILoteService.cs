using OVOCALIDAD.Application.DTOs.Lotes;

namespace OVOCALIDAD.Application.Interfaces;

public interface ILoteService
{
    Task<GenerarLoteResponse> GenerarLoteAsync(
        GenerarLoteRequest request);
}
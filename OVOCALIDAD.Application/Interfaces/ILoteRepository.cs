using OVOCALIDAD.Application.DTOs.Lotes;

namespace OVOCALIDAD.Application.Interfaces;

public interface ILoteRepository
{
    Task<GenerarLoteResponse> GenerarLoteAsync(GenerarLoteRequest request, string usuario);
    Task<IReadOnlyList<LoteListadoDto>> ListarLotesAsync(ListarLotesFiltro filtro);
    Task<CatalogosLoteDto> ObtenerCatalogosAsync();
    Task<DetalleLoteDto?> ObtenerDetalleAsync(int loteId);
}

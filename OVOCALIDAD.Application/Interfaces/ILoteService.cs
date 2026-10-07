using OVOCALIDAD.Application.DTOs.Lotes;

namespace OVOCALIDAD.Application.Interfaces;

public interface ILoteService
{
    Task<GenerarLoteResponse> GenerarLoteAsync(GenerarLoteRequest request, string usuario);
    Task<IReadOnlyList<LoteListadoDto>> ListarLotesAsync(ListarLotesFiltro filtro);
    Task<CatalogosLoteDto> ObtenerCatalogosAsync();
    Task<IReadOnlyList<ProductoGenesisDto>> BuscarProductosGenesisAsync(string? busqueda);
    Task<DetalleLoteDto?> ObtenerDetalleAsync(int loteId);
    Task<TrazabilidadLoteDto?> ObtenerTrazabilidadAsync(int loteId);
}

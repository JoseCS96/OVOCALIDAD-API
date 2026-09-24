using OVOCALIDAD.Shared.DTOs.GenerarLote;

namespace OVOCALIDAD.Application.DTOs.Lotes;

public class GenerarLoteResponse
{
    public ResultadoOperacionDto Resultado { get; set; } = new();

    public LoteDto? Lote { get; set; }
}
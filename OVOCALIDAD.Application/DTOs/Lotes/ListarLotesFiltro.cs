namespace OVOCALIDAD.Application.DTOs.Lotes;

public class ListarLotesFiltro
{
    public string? CodigoLote { get; set; }
    public string? ProductoCodigo { get; set; }
    public int? EstadoLoteId { get; set; }
    public int? EstadoEvaluacionId { get; set; }
    public DateTime? FechaDesde { get; set; }
    public DateTime? FechaHasta { get; set; }
}

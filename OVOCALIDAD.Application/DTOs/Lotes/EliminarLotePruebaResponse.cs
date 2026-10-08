namespace OVOCALIDAD.Application.DTOs.Lotes;

public class EliminarLotePruebaResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int LoteId { get; set; }
    public string CodigoLote { get; set; } = string.Empty;
    public string Usuario { get; set; } = string.Empty;
}

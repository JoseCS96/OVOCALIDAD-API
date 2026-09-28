namespace OVOCALIDAD.Application.DTOs.Evaluaciones;

public class GuardarResultadoRequest
{
    public int VersCaractId { get; set; }
    public string? ResultadoTexto { get; set; }
    public decimal? ResultadoNumerico { get; set; }
    public bool? Cumple { get; set; }
    public string? Observacion { get; set; }
}

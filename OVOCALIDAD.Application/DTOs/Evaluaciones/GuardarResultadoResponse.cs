namespace OVOCALIDAD.Application.DTOs.Evaluaciones;

public class GuardarResultadoResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? EvaluacionResultadoId { get; set; }
    public int? EvaluacionId { get; set; }
    public int? VersCaractId { get; set; }
    public string? TipoCriterio { get; set; }
    public string? TipoResultado { get; set; }
    public string? ResultadoTexto { get; set; }
    public decimal? ResultadoNumerico { get; set; }
    public bool? Cumple { get; set; }
    public int? EstadoEvaluacionId { get; set; }
    public string? EstadoEvaluacion { get; set; }
    public int? ErrorNumero { get; set; }
}

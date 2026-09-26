namespace OVOCALIDAD.Application.DTOs.Evaluaciones;

public class CerrarEvaluacionResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? EvaluacionId { get; set; }
    public int? EstadoEvaluacionId { get; set; }
    public string? EstadoEvaluacion { get; set; }
    public bool? ResultadoGeneral { get; set; }
    public string? ResultadoDescripcion { get; set; }
    public int? LoteId { get; set; }
    public int? EstadoLoteId { get; set; }
    public string? EstadoLote { get; set; }
    public int? TotalParametros { get; set; }
    public int? TotalObligatorios { get; set; }
    public int? ObligatoriosEvaluados { get; set; }
    public int? Cumplen { get; set; }
    public int? NoCumplen { get; set; }
    public int? ErrorNumero { get; set; }
    public int? ErrorLinea { get; set; }
    public string? ErrorProcedimiento { get; set; }
}
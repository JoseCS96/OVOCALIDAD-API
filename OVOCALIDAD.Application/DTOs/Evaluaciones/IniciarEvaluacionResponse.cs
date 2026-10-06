namespace OVOCALIDAD.Application.DTOs.Evaluaciones;

public class IniciarEvaluacionResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? EvaluacionId { get; set; }
    public int? LoteId { get; set; }
    public string? CodigoLote { get; set; }
    public string? UsuarioEvaluador { get; set; }

    public int? VersionFaseId { get; set; }
    public int? VersionFaseOrden { get; set; }
    public string? CodigoReferencia { get; set; }
    public string? FaseCodigo { get; set; }
    public bool? EsFinal { get; set; }

    public int? EvaluacionPadreId { get; set; }
    public bool EsReevaluacion { get; set; }

    public string? EstadoEvaluacion { get; set; }
    public string? EstadoLote { get; set; }
    public int? ErrorNumero { get; set; }
}

namespace OVOCALIDAD.Application.DTOs.Evaluaciones;

public class CrearEvaluacionRequest
{
    public int LoteId { get; set; }
    public int TipoEvaluacionId { get; set; }
    public int? EvaluacionPadreId { get; set; }
    public string? MotivoReevaluacion { get; set; }
    public string? Observacion { get; set; }
}

public class CrearEvaluacionResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? EvaluacionId { get; set; }
    public int? LoteId { get; set; }
    public string? CodigoLote { get; set; }
    public string? ProductoCodigo { get; set; }
    public int? VersionId { get; set; }
    public int? VersionFaseId { get; set; }
    public int? VersionFaseOrden { get; set; }
    public string? CodigoReferencia { get; set; }
    public string? FaseCodigo { get; set; }
    public bool? EsFinal { get; set; }
    public int? EvaluacionPadreId { get; set; }
    public short? Intento { get; set; }
    public string? UsuarioEvaluador { get; set; }
    public string? EstadoEvaluacion { get; set; }
    public int? ErrorNumero { get; set; }
    public int? ErrorLinea { get; set; }
    public string? ErrorProcedimiento { get; set; }
}

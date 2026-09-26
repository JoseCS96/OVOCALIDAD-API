namespace OVOCALIDAD.Application.DTOs.Evaluaciones;

public class TerminarEvaluacionResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? EvaluacionId { get; set; }
    public int? LoteId { get; set; }
    public string? CodigoLote { get; set; }
    public string? EstadoEvaluacion { get; set; }
    public string? EstadoLote { get; set; }
    public int? TotalParametros { get; set; }
    public int? ResultadosRegistrados { get; set; }
    public int? ResultadosPendientes { get; set; }
    public int? ErrorNumero { get; set; }
    public int? ErrorLinea { get; set; }
    public string? ErrorProcedimiento { get; set; }
}

public class SolicitarReaperturaRequest
{
    public string Motivo { get; set; } = string.Empty;
}

public class SolicitarReaperturaResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? SolicitudReaperturaId { get; set; }
    public int? EvaluacionId { get; set; }
    public int? LoteId { get; set; }
    public string? EstadoSolicitud { get; set; }
    public int? ErrorNumero { get; set; }
    public int? ErrorLinea { get; set; }
    public string? ErrorProcedimiento { get; set; }
}

public class ResolverReaperturaRequest
{
    public bool Aprobar { get; set; }
    public string? Observacion { get; set; }
}

public class ResolverReaperturaResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? SolicitudReaperturaId { get; set; }
    public int? EvaluacionId { get; set; }
    public int? LoteId { get; set; }
    public string? EstadoSolicitud { get; set; }
    public string? EstadoEvaluacion { get; set; }
    public int? ErrorNumero { get; set; }
    public int? ErrorLinea { get; set; }
    public string? ErrorProcedimiento { get; set; }
}

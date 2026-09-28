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


public class SolicitudReaperturaItemDto
{
    public int SolicitudReaperturaId { get; set; }
    public int EvaluacionId { get; set; }
    public int LoteId { get; set; }
    public string CodigoLote { get; set; } = string.Empty;
    public string ProductoCodigo { get; set; } = string.Empty;
    public string? ProductoDescripcion { get; set; }
    public int TipoEvaluacionId { get; set; }
    public short Intento { get; set; }
    public string? UsuarioEvaluador { get; set; }
    public string MotivoSolicitud { get; set; } = string.Empty;
    public string EstadoSolicitud { get; set; } = string.Empty;
    public string UsuarioSolicitante { get; set; } = string.Empty;
    public DateTime FechaSolicitud { get; set; }
    public string? UsuarioRespuesta { get; set; }
    public DateTime? FechaRespuesta { get; set; }
    public string? ObservacionRespuesta { get; set; }
    public bool LeidaPorMi { get; set; }
    public int TotalLecturas { get; set; }
    public string? EstadoLote { get; set; }
    public string? EstadoEvaluacion { get; set; }
}

public class SolicitudReaperturaDetalleDto
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int SolicitudReaperturaId { get; set; }
    public int EvaluacionId { get; set; }
    public int LoteId { get; set; }
    public string CodigoLote { get; set; } = string.Empty;
    public string ProductoCodigo { get; set; } = string.Empty;
    public string? ProductoDescripcion { get; set; }
    public int TipoEvaluacionId { get; set; }
    public short Intento { get; set; }
    public string? UsuarioEvaluador { get; set; }
    public string? EstadoEvaluacion { get; set; }
    public string? EstadoLote { get; set; }
    public DateTime? FechaInicio { get; set; }
    public DateTime? FechaFin { get; set; }
    public bool? ResultadoGeneral { get; set; }
    public string MotivoSolicitud { get; set; } = string.Empty;
    public string EstadoSolicitud { get; set; } = string.Empty;
    public string UsuarioSolicitante { get; set; } = string.Empty;
    public DateTime FechaSolicitud { get; set; }
    public string? UsuarioRespuesta { get; set; }
    public DateTime? FechaRespuesta { get; set; }
    public string? ObservacionRespuesta { get; set; }
    public List<SolicitudReaperturaLecturaDto> Lecturas { get; set; } = new();
}

public class SolicitudReaperturaLecturaDto
{
    public int SolicitudReaperturaLecturaId { get; set; }
    public int SolicitudReaperturaId { get; set; }
    public string UsuarioLectura { get; set; } = string.Empty;
    public DateTime FechaLectura { get; set; }
}

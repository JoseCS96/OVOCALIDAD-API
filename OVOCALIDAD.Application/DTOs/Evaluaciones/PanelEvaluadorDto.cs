namespace OVOCALIDAD.Application.DTOs.Evaluaciones;

public class PanelEvaluadorDto
{
    public PanelEvaluadorIndicadoresDto Indicadores { get; set; } = new();
    public List<PanelEvaluacionItemDto> PendientesDisponibles { get; set; } = new();
    public List<PanelEvaluacionItemDto> MisEvaluaciones { get; set; } = new();
    public List<PanelEvaluacionItemDto> AtendidasHoy { get; set; } = new();
    public List<PanelEvaluadorResumenEstadoDto> ResumenEstados { get; set; } = new();
}

public class PanelEvaluadorIndicadoresDto
{
    public int PendientesDisponibles { get; set; }
    public int PendientesAsignadas { get; set; }
    public int EnProceso { get; set; }
    public int AtendidasHoy { get; set; }
    public int IniciadasHoy { get; set; }
}

public class PanelEvaluacionItemDto
{
    public int EvaluacionId { get; set; }
    public int LoteId { get; set; }
    public string CodigoLote { get; set; } = string.Empty;
    public string ProductoCodigo { get; set; } = string.Empty;
    public string ProductoDescripcion { get; set; } = string.Empty;
    public int TipoEvaluacionId { get; set; }
    public string TipoEvaluacionCodigo { get; set; } = string.Empty;
    public string TipoEvaluacionDescripcion { get; set; } = string.Empty;
    public int EstadoEvaluacionId { get; set; }
    public string EstadoEvaluacionCodigo { get; set; } = string.Empty;
    public string EstadoEvaluacionDescripcion { get; set; } = string.Empty;
    public int EstadoLoteId { get; set; }
    public string EstadoLoteCodigo { get; set; } = string.Empty;
    public string EstadoLoteDescripcion { get; set; } = string.Empty;
    public short Intento { get; set; }
    public DateTime FechaHoraProduccion { get; set; }
    public DateTime? FechaCreacionEvaluacion { get; set; }
    public DateTime? FechaInicio { get; set; }
    public DateTime? FechaFin { get; set; }
    public bool? ResultadoGeneral { get; set; }
    public string? UsuarioEvaluador { get; set; }
    public string? MotivoReevaluacion { get; set; }
    public string? Observacion { get; set; }
    public DateTime? FechaUltimaActualizacion { get; set; }
}

public class PanelEvaluadorResumenEstadoDto
{
    public string EstadoCodigo { get; set; } = string.Empty;
    public string EstadoDescripcion { get; set; } = string.Empty;
    public int Cantidad { get; set; }
}

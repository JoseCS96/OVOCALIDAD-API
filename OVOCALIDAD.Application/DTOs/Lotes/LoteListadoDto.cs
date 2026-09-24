namespace OVOCALIDAD.Application.DTOs.Lotes;

public class LoteListadoDto
{
    public int LoteId { get; set; }
    public string CodigoLote { get; set; } = string.Empty;
    public string ProductoCodigo { get; set; } = string.Empty;
    public string ProductoDescripcion { get; set; } = string.Empty;
    public int Correlativo { get; set; }
    public DateTime FechaHoraProduccion { get; set; }

    public int NumeroCorrelativoId { get; set; }

    public int NaturalezaId { get; set; }
    public string NaturalezaCodigo { get; set; } = string.Empty;
    public string NaturalezaDescripcion { get; set; } = string.Empty;

    public int FaseId { get; set; }
    public string FaseCodigo { get; set; } = string.Empty;
    public string FaseDescripcion { get; set; } = string.Empty;

    public int LineaOrigenId { get; set; }
    public string LineaOrigenCodigo { get; set; } = string.Empty;
    public string LineaOrigenDescripcion { get; set; } = string.Empty;

    public int VersionId { get; set; }
    public decimal VersionNumero { get; set; }
    public DateTime VersionInicioVigencia { get; set; }
    public DateTime? VersionFinVigencia { get; set; }

    public int EstadoLoteId { get; set; }
    public string EstadoLoteCodigo { get; set; } = string.Empty;
    public string EstadoLoteDescripcion { get; set; } = string.Empty;

    public int? EvaluacionId { get; set; }
    public int? EvaluacionPadreId { get; set; }
    public int? TipoEvaluacionId { get; set; }
    public short? IntentoEvaluacion { get; set; }

    public int? EstadoEvaluacionId { get; set; }
    public string? EstadoEvaluacionCodigo { get; set; }
    public string? EstadoEvaluacionDescripcion { get; set; }

    public bool? ResultadoGeneral { get; set; }
    public DateTime? FechaInicioEvaluacion { get; set; }
    public DateTime? FechaFinEvaluacion { get; set; }
    public string? UsuarioEvaluador { get; set; }

    public string? Observacion { get; set; }
    public string Estado { get; set; } = string.Empty;
    public DateTime AudFechaCreacion { get; set; }
    public DateTime? AudFechaActualizacion { get; set; }
}

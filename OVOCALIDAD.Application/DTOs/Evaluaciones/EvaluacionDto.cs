namespace OVOCALIDAD.Application.DTOs.Evaluaciones;

public class EvaluacionDto
{
    public EvaluacionCabeceraDto Cabecera { get; set; } = new();
    public IReadOnlyList<EvaluacionDetalleDto> Detalle { get; set; } = [];
    public EvaluacionAvanceDto Avance { get; set; } = new();
}

public class EvaluacionCabeceraDto
{
    public int EvaluacionId { get; set; }
    public int LoteId { get; set; }
    public string CodigoLote { get; set; } = string.Empty;
    public string ProductoCodigo { get; set; } = string.Empty;
    public string ProductoDescripcion { get; set; } = string.Empty;
    public int DocumentoId { get; set; }
    public string DocumentoCodigo { get; set; } = string.Empty;
    public string DocumentoDescripcionDocumento { get; set; } = string.Empty;
    public int VersionId { get; set; }
    public decimal VersionNumero { get; set; }
    public int TipoEvaluacionId { get; set; }
    public string TipoEvaluacion { get; set; } = string.Empty;
    public int EstadoEvaluacionId { get; set; }
    public string EstadoEvaluacion { get; set; } = string.Empty;
    public short Intento { get; set; }
    public string UsuarioEvaluador { get; set; } = string.Empty;
    public DateTime FechaInicio { get; set; }
    public DateTime? FechaFin { get; set; }
    public string? Observacion { get; set; }
}

public class EvaluacionDetalleDto
{
    public int VersCaractId { get; set; }
    public string TipoCaracteristica { get; set; } = string.Empty;
    public string Caracteristica { get; set; } = string.Empty;
    public int? TipoCriterioId { get; set; }
    public string? TipoCriterio { get; set; }
    public string? Especificacion { get; set; }
    public string? Unidad { get; set; }
    public string? MetodoEnsayo { get; set; }
    public int Orden { get; set; }
    public bool EsObligatorio { get; set; }
    public string TipoResultado { get; set; } = string.Empty;
    public decimal? ResultadoNumerico { get; set; }
    public string? ResultadoTexto { get; set; }
    public bool? Cumple { get; set; }
    public bool PermiteEditar { get; set; }
}

public class EvaluacionAvanceDto
{
    public int TotalCaracteristicas { get; set; }
    public int TotalObligatorias { get; set; }
    public int ResultadosRegistrados { get; set; }
    public int ObligatoriasCompletas { get; set; }
}

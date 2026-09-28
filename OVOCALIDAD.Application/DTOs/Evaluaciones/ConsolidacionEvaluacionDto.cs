namespace OVOCALIDAD.Application.DTOs.Evaluaciones;

public class EvaluacionPendienteCalculoDto
{
    public int EvaluacionId { get; set; }
    public int LoteId { get; set; }
    public string CodigoLote { get; set; } = string.Empty;
    public string ProductoCodigo { get; set; } = string.Empty;
    public string ProductoDescripcion { get; set; } = string.Empty;
    public int TipoEvaluacionId { get; set; }
    public short Intento { get; set; }
    public string? UsuarioEvaluador { get; set; }
    public DateTime? FechaInicio { get; set; }
    public DateTime? FechaFin { get; set; }
    public string EstadoEvaluacion { get; set; } = string.Empty;
    public string EstadoLote { get; set; } = string.Empty;
    public int TotalParametros { get; set; }
    public int ResultadosRegistrados { get; set; }
    public int TotalObligatorios { get; set; }
    public int ObligatoriosRegistrados { get; set; }
    public int ParametrosCumplen { get; set; }
    public int ParametrosNoCumplen { get; set; }
    public string Precalculo { get; set; } = string.Empty;
    public int ResultadosPendientes { get; set; }
}

public class PrecalculoEvaluacionesRequest
{
    public List<int> EvaluacionIds { get; set; } = [];
}

public class ConsolidarEvaluacionesRequest
{
    public List<int> EvaluacionIds { get; set; } = [];
    public string? Observacion { get; set; }
}

public class PrecalculoEvaluacionDto : EvaluacionPendienteCalculoDto
{
    public string AccionPropuesta { get; set; } = string.Empty;
    public bool EsCalculable { get; set; }
}

public class PrecalculoDetalleDto
{
    public int EvaluacionId { get; set; }
    public int LoteId { get; set; }
    public string CodigoLote { get; set; } = string.Empty;
    public int VersCaractId { get; set; }
    public int CaracteristicaId { get; set; }
    public string CaracteristicaDescripcion { get; set; } = string.Empty;
    public int TipoCaractId { get; set; }
    public string TipoCaractDescripcion { get; set; } = string.Empty;
    public int TipoCriterioId { get; set; }
    public string TipoCriterio { get; set; } = string.Empty;
    public decimal? ValorCuantitativoInicial { get; set; }
    public decimal? ValorCuantitativoFinal { get; set; }
    public decimal? ValorCuantitativoIgual { get; set; }
    public string? ValorCualitativo { get; set; }
    public string? Unidad { get; set; }
    public bool EsObligatorio { get; set; }
    public int? Orden { get; set; }
    public int? EvaluacionResultadoId { get; set; }
    public decimal? ResultadoNumerico { get; set; }
    public string? ResultadoTexto { get; set; }
    public bool? Cumple { get; set; }
    public string? Observacion { get; set; }
    public string EstadoResultado { get; set; } = string.Empty;
    public string? Especificacion { get; set; }
}

public class PrecalculoEvaluacionesResponse
{
    public List<PrecalculoEvaluacionDto> Evaluaciones { get; set; } = [];
    public List<PrecalculoDetalleDto> Detalle { get; set; } = [];
}

public class ConsolidacionEvaluacionResultadoDto
{
    public int EvaluacionId { get; set; }
    public int? LoteId { get; set; }
    public string? CodigoLote { get; set; }
    public string? ProductoCodigo { get; set; }
    public string? Precalculo { get; set; }
    public string? Accion { get; set; }
    public bool Procesado { get; set; }
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
}

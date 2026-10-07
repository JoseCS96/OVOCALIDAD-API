namespace OVOCALIDAD.Application.DTOs.Lotes;

public class TrazabilidadLoteDto
{
    public TrazabilidadLoteCabeceraDto? Lote { get; set; }
    public IReadOnlyList<TrazabilidadEtapaDto> Etapas { get; set; } = [];
    public IReadOnlyList<TrazabilidadEvaluacionDto> Evaluaciones { get; set; } = [];
    public IReadOnlyList<TrazabilidadResultadoDto> Resultados { get; set; } = [];
    public IReadOnlyList<TrazabilidadEstadoDto> HistorialEstados { get; set; } = [];
}

public class TrazabilidadLoteCabeceraDto
{
    public int LoteId { get; set; }
    public string CodigoLote { get; set; } = string.Empty;
    public string? CodigoGenesis { get; set; }
    public string? ProductoCodigo { get; set; }
    public string? ProductoDescripcion { get; set; }
    public DateTime FechaHoraProduccion { get; set; }
    public int VersionId { get; set; }
    public decimal VersionNumero { get; set; }
    public int DocumentoId { get; set; }
    public string DocumentoCodigo { get; set; } = string.Empty;
    public string DocumentoDescripcionDocumento { get; set; } = string.Empty;
    public int EstadoLoteId { get; set; }
    public string EstadoLoteCodigo { get; set; } = string.Empty;
    public string EstadoLoteDescripcion { get; set; } = string.Empty;
    public string? Observacion { get; set; }
    public string? AudUsuarioCreacion { get; set; }
    public DateTime AudFechaCreacion { get; set; }
    public string? AudUsuarioModificacion { get; set; }
    public DateTime? AudFechaActualizacion { get; set; }
}

public class TrazabilidadEtapaDto
{
    public int VersionFaseId { get; set; }
    public int Orden { get; set; }
    public string CodigoReferencia { get; set; } = string.Empty;
    public int FaseId { get; set; }
    public string FaseCodigo { get; set; } = string.Empty;
    public string FaseDescripcion { get; set; } = string.Empty;
    public bool EsFinal { get; set; }
    public bool EsObligatoria { get; set; }
    public int CantidadCaracteristicas { get; set; }
}

public class TrazabilidadEvaluacionDto
{
    public int EvaluacionId { get; set; }
    public int? EvaluacionPadreId { get; set; }
    public short Intento { get; set; }
    public int? VersionFaseId { get; set; }
    public int? EtapaOrden { get; set; }
    public string? CodigoReferencia { get; set; }
    public string? FaseCodigo { get; set; }
    public string? FaseDescripcion { get; set; }
    public bool? EsFinal { get; set; }
    public int TipoEvaluacionId { get; set; }
    public string TipoEvaluacionCodigo { get; set; } = string.Empty;
    public string TipoEvaluacionDescripcion { get; set; } = string.Empty;
    public int EstadoEvaluacionId { get; set; }
    public string EstadoEvaluacionCodigo { get; set; } = string.Empty;
    public string EstadoEvaluacionDescripcion { get; set; } = string.Empty;
    public bool? ResultadoGeneral { get; set; }
    public string ResultadoDescripcion { get; set; } = string.Empty;
    public string? UsuarioEvaluador { get; set; }
    public DateTime? FechaInicio { get; set; }
    public DateTime? FechaFin { get; set; }
    public string? MotivoReevaluacion { get; set; }
    public string? Observacion { get; set; }
    public string? AudUsuarioCreacion { get; set; }
    public DateTime AudFechaCreacion { get; set; }
    public string? AudUsuarioModificacion { get; set; }
    public DateTime? AudFechaActualizacion { get; set; }
}

public class TrazabilidadResultadoDto
{
    public int EvaluacionResultadoId { get; set; }
    public int EvaluacionId { get; set; }
    public short Intento { get; set; }
    public int? VersionFaseId { get; set; }
    public int? EtapaOrden { get; set; }
    public string? CodigoReferencia { get; set; }
    public int VersCaractId { get; set; }
    public int CaracteristicaId { get; set; }
    public string Caracteristica { get; set; } = string.Empty;
    public string TipoCriterio { get; set; } = string.Empty;
    public decimal? ValorCuantitativoInicial { get; set; }
    public decimal? ValorCuantitativoFinal { get; set; }
    public decimal? ValorCuantitativoIgual { get; set; }
    public string? ValorCualitativo { get; set; }
    public string? UnidadDeMedida { get; set; }
    public decimal? ResultadoNumerico { get; set; }
    public string? ResultadoTexto { get; set; }
    public bool? Cumple { get; set; }
    public DateTime FechaResultado { get; set; }
    public string? Observacion { get; set; }
    public string? AudUsuarioCreacion { get; set; }
    public DateTime AudFechaCreacion { get; set; }
    public string? AudUsuarioModificacion { get; set; }
    public DateTime? AudFechaActualizacion { get; set; }
}

public class TrazabilidadEstadoDto
{
    public int LoteHistorialEstadoId { get; set; }
    public int LoteId { get; set; }
    public int? EstadoLoteOrigenId { get; set; }
    public string? EstadoOrigen { get; set; }
    public int EstadoLoteDestinoId { get; set; }
    public string EstadoDestino { get; set; } = string.Empty;
    public string Accion { get; set; } = string.Empty;
    public string? Comentario { get; set; }
    public string Usuario { get; set; } = string.Empty;
    public DateTime Fecha { get; set; }
}

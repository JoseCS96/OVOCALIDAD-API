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
    public string? CodigoGenesis { get; set; }
    public string ProductoDescripcion { get; set; } = string.Empty;
    public int? Kardex { get; set; }

    public int DocumentoId { get; set; }
    public string DocumentoCodigo { get; set; } = string.Empty;
    public string DocumentoDescripcionDocumento { get; set; } = string.Empty;
    public int VersionId { get; set; }
    public decimal VersionNumero { get; set; }

    public int? VersionFaseId { get; set; }
    public int? VersionFaseOrden { get; set; }
    public string? CodigoReferencia { get; set; }
    public string? VersionFaseDescripcion { get; set; }
    public int? FaseId { get; set; }
    public string? FaseCodigo { get; set; }
    public string? FaseDescripcion { get; set; }
    public bool? EsFinal { get; set; }
    public bool? VersionFaseEsObligatoria { get; set; }

    public int TipoEvaluacionId { get; set; }
    public string TipoEvaluacion { get; set; } = string.Empty;
    public int EstadoEvaluacionId { get; set; }
    public string EstadoEvaluacion { get; set; } = string.Empty;
    public short Intento { get; set; }
    public int? EvaluacionPadreId { get; set; }
    public string UsuarioEvaluador { get; set; } = string.Empty;
    public DateTime? FechaInicio { get; set; }
    public DateTime? FechaFin { get; set; }
    public string? MotivoReevaluacion { get; set; }
    public string? Observacion { get; set; }
    public bool? ResultadoGeneral { get; set; }
    public bool EsReevaluacion { get; set; }
}

public class EvaluacionDetalleDto
{
    public int VersCaractId { get; set; }

    public int? VersionFaseId { get; set; }
    public int? VersionFaseOrden { get; set; }
    public string? CodigoReferencia { get; set; }
    public bool? EsFinal { get; set; }

    public int OrdenGeneral { get; set; }
    public int TipoCaractId { get; set; }
    public string TipoCaracteristica { get; set; } = string.Empty;
    public int Item { get; set; }
    public bool EsInicioGrupo { get; set; }
    public int Orden { get; set; }
    public string? Fase { get; set; }

    public int CaracteristicaId { get; set; }
    public string Caracteristica { get; set; } = string.Empty;
    public string? Unidad { get; set; }
    public string? MetodoEnsayo { get; set; }

    public int? TipoCriterioId { get; set; }
    public string? TipoCriterio { get; set; }
    public bool EsObligatorio { get; set; }
    public decimal? ValorCuantitativoInicial { get; set; }
    public decimal? ValorCuantitativoFinal { get; set; }
    public decimal? ValorCuantitativoIgual { get; set; }
    public string? ValorCualitativo { get; set; }
    public string? Especificacion { get; set; }
    public string TipoResultado { get; set; } = string.Empty;

    public int? EvaluacionResultadoId { get; set; }
    public string? ResultadoTexto { get; set; }
    public decimal? ResultadoNumerico { get; set; }
    public string? Resultado { get; set; }
    public string? Observacion { get; set; }
    public bool? Cumple { get; set; }
    public string? CumpleDescripcion { get; set; }
    public bool TieneResultado { get; set; }
    public bool TieneObservacion { get; set; }
    public bool PermiteEditar { get; set; }

    public int? EvaluacionPadreId { get; set; }
    public int? EvaluacionResultadoPadreId { get; set; }
    public string? ResultadoTextoAnterior { get; set; }
    public decimal? ResultadoNumericoAnterior { get; set; }
    public bool? CumpleAnterior { get; set; }
    public string? ObservacionAnterior { get; set; }
}

public class EvaluacionAvanceDto
{
    public int TotalCaracteristicas { get; set; }
    public int TotalObligatorias { get; set; }
    public int ResultadosRegistrados { get; set; }
    public int ObligatoriasCompletas { get; set; }
    public int ParametrosPendientes { get; set; }
    public decimal PorcentajeAvance { get; set; }
}

namespace OVOCALIDAD.Application.DTOs.EspecificacionesTecnicas;

public class DetalleEspecificacionTecnicaDto
{
    public InformacionGeneralEtDto InformacionGeneral { get; set; } = new();
    public IReadOnlyList<SeccionEtDto> Secciones { get; set; } = [];
    public IReadOnlyList<ResponsableEtDto> Responsables { get; set; } = [];
    public IReadOnlyList<IngredienteEtDto> Ingredientes { get; set; } = [];
    public IReadOnlyList<RecetaEtDto> Recetas { get; set; } = [];
    public IReadOnlyList<ProcedimientoEtDto> Procedimientos { get; set; } = [];
    public IReadOnlyList<TratamientoEtDto> Tratamientos { get; set; } = [];
    public IReadOnlyList<ParametroTratamientoEtDto> ParametrosTratamiento { get; set; } = [];
    public IReadOnlyList<CaracteristicaVersionEtDto> Caracteristicas { get; set; } = [];
    public IReadOnlyList<InstruccionEtDto> Instrucciones { get; set; } = [];
    public IReadOnlyList<ContenidoRotuladoEtDto> ContenidoRotulado { get; set; } = [];
    public IReadOnlyList<CambioVersionEtDto> CambiosVersion { get; set; } = [];
    public IReadOnlyList<AnexoEtDto> Anexos { get; set; } = [];
    public IReadOnlyList<HistorialEstadoEtDto> Historial { get; set; } = [];
}

public class InformacionGeneralEtDto
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int DocumentoId { get; set; }
    public string DocumentoCodigo { get; set; } = string.Empty;
    public string DocumentoDescripcionDocumento { get; set; } = string.Empty;
    public int TipoDocumentoId { get; set; }
    public string TipoDocumentoDescripcion { get; set; } = string.Empty;
    public string ProductoCodigo { get; set; } = string.Empty;
    public string ProductoDescripcion { get; set; } = string.Empty;
    public int VersionId { get; set; }
    public decimal? VersionNumero { get; set; }
    public int EstVerId { get; set; }
    public string EstadoVersion { get; set; } = string.Empty;
    public DateTime? VersionInicioVigencia { get; set; }
    public DateTime? VersionFinVigencia { get; set; }
    public int? VersionReemplazaAId { get; set; }
    public decimal? VersionReemplazadaNumero { get; set; }
    public int? VersionNroPaginas { get; set; }
    public DateTime? VersionFechaFirmado { get; set; }
    public string? VersionDescripcion { get; set; }
    public int? EnvyEmbId { get; set; }
    public string? EnvyEmbDescripcion { get; set; }
    public int? AlmacyDistId { get; set; }
    public string? AlmacyDistDescripcion { get; set; }
    public int? VidaUtilId { get; set; }
    public string? VidaUtilDescripcion { get; set; }
    public int? DescongelamientoId { get; set; }
    public string? DescongelamientoDescripcion { get; set; }
    public int? CantidadHojasAnexo { get; set; }
    public bool PermiteEditar { get; set; }
    public bool PermiteEnviarRevision { get; set; }
    public bool PermiteRevisar { get; set; }
    public bool PermitePublicar { get; set; }
    public string AudUsuarioCreacion { get; set; } = string.Empty;
    public DateTime AudFechaCreacion { get; set; }
    public string? AudUsuarioModificacion { get; set; }
    public DateTime? AudFechaActualizacion { get; set; }
}

public class SeccionEtDto
{
    public int VersSeccId { get; set; }
    public int VersionId { get; set; }
    public int SeccionId { get; set; }
    public string SeccionDescripcion { get; set; } = string.Empty;
    public int? Orden { get; set; }
    public int? IdTipoSeccion { get; set; }
    public string? TipoSeccionDescripcion { get; set; }
    public bool EsBase { get; set; }
    public bool PuedeEliminarse { get; set; }
    public bool PermiteReordenar { get; set; }
    public string? Icono { get; set; }
}

public class ResponsableEtDto
{
    public string TipoResponsabilidad { get; set; } = string.Empty;
    public int IdRelacion { get; set; }
    public string UsuarioDni { get; set; } = string.Empty;
    public string UsuarioNombresApellidos { get; set; } = string.Empty;
    public int? CargoId { get; set; }
}

public class IngredienteEtDto
{
    public int VersIngrId { get; set; }
    public int IngredienteId { get; set; }
    public string IngredienteDescripcion { get; set; } = string.Empty;
    public string? UnidadDeMedida { get; set; }
    public decimal? VersIngrValor { get; set; }
    public int? IdTipoContenido { get; set; }
    public string? TipoContenidoCodigo { get; set; }
    public string? TipoContenido { get; set; }
    public int? Orden { get; set; }
}

public class RecetaEtDto
{
    public int VersRectId { get; set; }
    public int RecetaId { get; set; }
    public string RecetaDescripcion { get; set; } = string.Empty;
    public int? IdTipoContenido { get; set; }
    public string? TipoContenidoCodigo { get; set; }
    public string? TipoContenido { get; set; }
    public int? Orden { get; set; }
}

public class ProcedimientoEtDto
{
    public int VersProcId { get; set; }
    public int ProcPrepId { get; set; }
    public string ProcPrepDescripcion { get; set; } = string.Empty;
    public int? IdTipoContenido { get; set; }
    public string? TipoContenidoCodigo { get; set; }
    public string? TipoContenido { get; set; }
    public int? Orden { get; set; }
}

public class TratamientoEtDto
{
    public int VersTratConsId { get; set; }
    public int TratConservId { get; set; }
    public string TratConservDescripcion { get; set; } = string.Empty;
}

public class ParametroTratamientoEtDto
{
    public int VersParamTratId { get; set; }
    public int VersTratConsId { get; set; }
    public int ParametroTratId { get; set; }
    public string ParamTratDescripcion { get; set; } = string.Empty;
    public string? ParamTratUnidadDeMedida { get; set; }
    public int TipoCriterioId { get; set; }
    public string TipoCriterio { get; set; } = string.Empty;
    public decimal? ValorCuantitativoInicial { get; set; }
    public decimal? ValorCuantitativoFinal { get; set; }
    public decimal? ValorCuantitativoIgual { get; set; }
    public string? ValorCualitativo { get; set; }
    public int? Orden { get; set; }
}

public class CaracteristicaVersionEtDto
{
    public int VersCaractId { get; set; }
    public int CaracteristicaId { get; set; }
    public int TipoCaractId { get; set; }
    public string TipoCaracteristica { get; set; } = string.Empty;
    public string Caracteristica { get; set; } = string.Empty;
    public string? Unidad { get; set; }
    public int? MetEnsayoId { get; set; }
    public string? MetodoEnsayo { get; set; }
    public int? TipoCriterioId { get; set; }
    public string? TipoCriterio { get; set; }
    public decimal? ValorCuantitativoInicial { get; set; }
    public decimal? ValorCuantitativoFinal { get; set; }
    public decimal? ValorCuantitativoIgual { get; set; }
    public string? ValorCualitativo { get; set; }
    public int? FaseId { get; set; }
    public string? FaseCodigo { get; set; }
    public string? Fase { get; set; }
    public bool EsObligatorio { get; set; }
    public int? Orden { get; set; }
}

public class InstruccionEtDto
{
    public int VersInstrId { get; set; }
    public int InstruccionId { get; set; }
    public string InstruccionDescripcion { get; set; } = string.Empty;
    public int? Orden { get; set; }
}

public class ContenidoRotuladoEtDto
{
    public int VersContRotId { get; set; }
    public int ContRotuladoId { get; set; }
    public string ContRotuladoDescripcion { get; set; } = string.Empty;
    public int? Orden { get; set; }
}

public class CambioVersionEtDto
{
    public int VersCambId { get; set; }
    public int CambVersiId { get; set; }
    public int CambVersNumeroDeRevision { get; set; }
    public DateTime? CambVersFechaDeActualizacion { get; set; }
    public string CambVersDescripcion { get; set; } = string.Empty;
}

public class AnexoEtDto
{
    public int VersionAnexoId { get; set; }
    public int AnexoId { get; set; }
    public string AnexoDescripcion { get; set; } = string.Empty;
}

public class HistorialEstadoEtDto
{
    public int VersionHistorialEstadoId { get; set; }
    public int? EstVerOrigenId { get; set; }
    public string? EstadoOrigen { get; set; }
    public int EstVerDestinoId { get; set; }
    public string EstadoDestino { get; set; } = string.Empty;
    public string Accion { get; set; } = string.Empty;
    public string? Comentario { get; set; }
    public string Usuario { get; set; } = string.Empty;
    public DateTime Fecha { get; set; }
}

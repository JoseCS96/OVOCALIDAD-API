namespace OVOCALIDAD.Application.DTOs.EspecificacionesTecnicas;

public class GuardarInformacionGeneralEtRequest
{
    public string DocumentoDescripcionDocumento { get; set; } = string.Empty;
    public string ProductoCodigo { get; set; } = string.Empty;
    public decimal? VersionNumero { get; set; }
    public DateTime? VersionInicioVigencia { get; set; }
    public int? VersionReemplazaAId { get; set; }
    public int? VersionNroPaginas { get; set; }
    public string? VersionDescripcion { get; set; }
    public string Usuario { get; set; } = string.Empty;
}

public class GuardarInformacionGeneralEtResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? DocumentoId { get; set; }
    public int? VersionId { get; set; }
    public string? DocumentoCodigo { get; set; }
    public string? ProductoCodigo { get; set; }
    public decimal? VersionNumero { get; set; }
    public string? EstadoVersion { get; set; }
}

public class GuardarContenidoBaseEtRequest
{
    public string TipoContenido { get; set; } = string.Empty;
    public string? Contenido { get; set; }
    public string Usuario { get; set; } = string.Empty;
}

public class GuardarContenidoBaseEtResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? VersionId { get; set; }
    public string? TipoContenido { get; set; }
}

public class ResponsableEtCatalogoDto
{
    public int UsuarioCargoHistorialId { get; set; }
    public string UsuarioDni { get; set; } = string.Empty;
    public string UsuarioNombresApellidos { get; set; } = string.Empty;
    public int CargoId { get; set; }
    public string CargoDescripcion { get; set; } = string.Empty;
    public bool CargoActual { get; set; }
    public DateTime? FechaInicio { get; set; }
    public DateTime? FechaFin { get; set; }
}

public class GuardarResponsablesEtRequest
{
    public IReadOnlyList<int> ElaboradoPor { get; set; } = [];
    public IReadOnlyList<int> RevisadoPor { get; set; } = [];
    public IReadOnlyList<int> AprobadoPor { get; set; } = [];
    public string Usuario { get; set; } = string.Empty;
}

public class GuardarResponsablesEtResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? VersionId { get; set; }
    public int? CantidadElaboradores { get; set; }
    public int? CantidadRevisores { get; set; }
    public int? CantidadAprobadores { get; set; }
}

public class IngredienteEtCatalogoDto
{
    public int IngredienteId { get; set; }
    public string IngredienteDescripcion { get; set; } = string.Empty;
    public string? UnidadDeMedida { get; set; }
}

public class TipoContenidoEtCatalogoDto
{
    public int IdTipoContenido { get; set; }
    public string Codigo { get; set; } = string.Empty;
    public string Nombre { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
}

public class CatalogosIngredientesEtDto
{
    public IReadOnlyList<IngredienteEtCatalogoDto> Ingredientes { get; set; } = [];
    public IReadOnlyList<TipoContenidoEtCatalogoDto> TiposContenido { get; set; } = [];
}

public class GuardarIngredienteEtItemRequest
{
    public int IngredienteId { get; set; }
    public decimal? Valor { get; set; }
    public int? IdTipoContenido { get; set; }
    public int Orden { get; set; }
}

public class GuardarIngredientesEtRequest
{
    public IReadOnlyList<GuardarIngredienteEtItemRequest> Ingredientes { get; set; } = [];
    public string Usuario { get; set; } = string.Empty;
}

public class GuardarIngredientesEtResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? VersionId { get; set; }
    public int? CantidadIngredientes { get; set; }
}

public class GuardarRecetaEtItemRequest
{
    public string Descripcion { get; set; } = string.Empty;
    public int? IdTipoContenido { get; set; }
    public int Orden { get; set; }
}

public class GuardarRecetasEtRequest
{
    public IReadOnlyList<GuardarRecetaEtItemRequest> Recetas { get; set; } = [];
    public string Usuario { get; set; } = string.Empty;
}

public class GuardarRecetasEtResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? VersionId { get; set; }
    public int? CantidadRecetas { get; set; }
}

public class GuardarProcedimientoEtItemRequest
{
    public string Descripcion { get; set; } = string.Empty;
    public int? IdTipoContenido { get; set; }
    public int Orden { get; set; }
}

public class GuardarProcedimientosEtRequest
{
    public IReadOnlyList<GuardarProcedimientoEtItemRequest> Procedimientos { get; set; } = [];
    public string Usuario { get; set; } = string.Empty;
}

public class GuardarProcedimientosEtResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? VersionId { get; set; }
    public int? CantidadProcedimientos { get; set; }
}

public class TratamientoEtCatalogoDto
{
    public int TratConservId { get; set; }
    public string TratConservDescripcion { get; set; } = string.Empty;
}
public class ParametroTratamientoEtCatalogoDto
{
    public int ParamTratId { get; set; }
    public string ParamTratDescripcion { get; set; } = string.Empty;
    public string? ParamTratUnidadDeMedida { get; set; }
}
public class TipoCriterioTratamientoEtCatalogoDto
{
    public int TipoCriterioId { get; set; }
    public string TipCritDescripcion { get; set; } = string.Empty;
}
public class CatalogosTratamientosEtDto
{
    public IReadOnlyList<TratamientoEtCatalogoDto> Tratamientos { get; set; } = [];
    public IReadOnlyList<ParametroTratamientoEtCatalogoDto> Parametros { get; set; } = [];
    public IReadOnlyList<TipoCriterioTratamientoEtCatalogoDto> TiposCriterio { get; set; } = [];
}
public class GuardarParametroTratamientoEtItemRequest
{
    public int ParametroTratId { get; set; }
    public int TipoCriterioId { get; set; }
    public decimal? ValorCuantitativoInicial { get; set; }
    public decimal? ValorCuantitativoFinal { get; set; }
    public decimal? ValorCuantitativoIgual { get; set; }
    public string? ValorCualitativo { get; set; }
    public int Orden { get; set; }
}
public class GuardarTratamientoEtItemRequest
{
    public int TratConservId { get; set; }
    public IReadOnlyList<GuardarParametroTratamientoEtItemRequest> Parametros { get; set; } = [];
}
public class GuardarTratamientosEtRequest
{
    public IReadOnlyList<GuardarTratamientoEtItemRequest> Tratamientos { get; set; } = [];
    public string Usuario { get; set; } = string.Empty;
}
public class GuardarTratamientosEtResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? VersionId { get; set; }
    public int? CantidadTratamientos { get; set; }
    public int? CantidadParametros { get; set; }
}

public class GuardarInstruccionEtItemRequest
{
    public string Descripcion { get; set; } = string.Empty;
    public int Orden { get; set; }
}
public class GuardarInstruccionesEtRequest
{
    public IReadOnlyList<GuardarInstruccionEtItemRequest> Instrucciones { get; set; } = [];
    public string Usuario { get; set; } = string.Empty;
}
public class GuardarInstruccionesEtResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? VersionId { get; set; }
    public int? CantidadInstrucciones { get; set; }
}

public class ContenidoRotuladoCatalogoDto
{
    public int ContRotuladoId { get; set; }
    public string ContRotuladoDescripcion { get; set; } = string.Empty;
}
public class GuardarContenidoRotuladoItemRequest
{
    public int ContRotuladoId { get; set; }
    public int Orden { get; set; }
}
public class GuardarContenidoRotuladoEtRequest
{
    public IReadOnlyList<GuardarContenidoRotuladoItemRequest> ContenidoRotulado { get; set; } = [];
    public string Usuario { get; set; } = string.Empty;
}
public class GuardarContenidoRotuladoEtResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? VersionId { get; set; }
    public int? CantidadContenidoRotulado { get; set; }
}

public class GuardarAnexoEtItemRequest
{
    public string Descripcion { get; set; } = string.Empty;
}
public class GuardarAnexosEtRequest
{
    public IReadOnlyList<GuardarAnexoEtItemRequest> Anexos { get; set; } = [];
    public string Usuario { get; set; } = string.Empty;
}
public class GuardarAnexosEtResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? VersionId { get; set; }
    public int? CantidadAnexos { get; set; }
}

public class GuardarCambioEtItemRequest
{
    public int NumeroRevision { get; set; }
    public DateTime FechaActualizacion { get; set; }
    public string Descripcion { get; set; } = string.Empty;
}
public class GuardarCambiosEtRequest
{
    public IReadOnlyList<GuardarCambioEtItemRequest> Cambios { get; set; } = [];
    public string Usuario { get; set; } = string.Empty;
}
public class GuardarCambiosEtResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? VersionId { get; set; }
    public int? CantidadCambios { get; set; }
}

public class GuardarCaracteristicaEtRequest
{
    public int? VersCaractId { get; set; }
    public int CaracteristicaId { get; set; }
    public int TipoCriterioId { get; set; }
    public decimal? ValorCuantitativoInicial { get; set; }
    public decimal? ValorCuantitativoFinal { get; set; }
    public decimal? ValorCuantitativoIgual { get; set; }
    public string? ValorCualitativo { get; set; }
    public int? FaseId { get; set; }
    public bool EsObligatorio { get; set; } = true;
    public int Orden { get; set; }
    public string Usuario { get; set; } = string.Empty;
}

public class GuardarCaracteristicaEtResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? VersCaractId { get; set; }
    public int? VersionId { get; set; }
    public int? CaracteristicaId { get; set; }
    public int? TipoCriterioId { get; set; }
    public string? TipoCriterio { get; set; }
    public decimal? ValorCuantitativoInicial { get; set; }
    public decimal? ValorCuantitativoFinal { get; set; }
    public decimal? ValorCuantitativoIgual { get; set; }
    public string? ValorCualitativo { get; set; }
    public int? FaseId { get; set; }
    public bool? EsObligatorio { get; set; }
    public int? Orden { get; set; }
}

public class EliminarCaracteristicaEtRequest
{
    public string Usuario { get; set; } = string.Empty;
}

public class EliminarCaracteristicaEtResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? VersionId { get; set; }
    public int? VersCaractId { get; set; }
    public int? CaracteristicaId { get; set; }
    public string? Caracteristica { get; set; }
}


public class CrearEspecificacionTecnicaRequest
{
    public string DocumentoCodigo { get; set; } = string.Empty;
    public string DocumentoDescripcionDocumento { get; set; } = string.Empty;
    public IReadOnlyList<PresentacionGenesisEtRequest> PresentacionesGenesis { get; set; } = [];
    public decimal VersionNumero { get; set; } = 1;
    public DateTime? VersionInicioVigencia { get; set; }
    public int? VersionReemplazaAId { get; set; }
    public int? VersionNroPaginas { get; set; }
    public List<CrearEspecificacionTecnicaSeccionRequest> Secciones { get; set; } = new();
    public string Usuario { get; set; } = string.Empty;
}

public class CrearEspecificacionTecnicaSeccionRequest
{
    public int SeccionId { get; set; }
    public int Orden { get; set; }
}

public class CrearEspecificacionTecnicaResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? DocumentoId { get; set; }
    public int? VersionId { get; set; }
    public string? DocumentoCodigo { get; set; }
    public string? ProductoCodigo { get; set; }
    public decimal? VersionNumero { get; set; }
    public string? EstadoVersion { get; set; }
}


public class SeccionesEtCatalogoDto
{
    public IReadOnlyList<SeccionDisponibleEtDto> Secciones { get; set; } = [];
    public IReadOnlyList<TipoSeccionEtDto> TiposSeccion { get; set; } = [];
}

public class SeccionDisponibleEtDto
{
    public int SeccionId { get; set; }
    public string SeccionDescripcion { get; set; } = string.Empty;
    public int? IdTipoSeccion { get; set; }
    public string? TipoSeccion { get; set; }
    public int OrdenDefault { get; set; }
    public bool EsBase { get; set; }
    public bool PuedeEliminarse { get; set; }
    public bool PermiteReordenar { get; set; }
    public string? Icono { get; set; }
}

public class TipoSeccionEtDto
{
    public int IdTipoSeccion { get; set; }
    public string Descripcion { get; set; } = string.Empty;
}

public class CrearSeccionEtRequest
{
    public string SeccionDescripcion { get; set; } = string.Empty;
    public int IdTipoSeccion { get; set; }
    public string Usuario { get; set; } = string.Empty;
}

public class CrearSeccionEtResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? SeccionId { get; set; }
    public string? SeccionDescripcion { get; set; }
    public int? IdTipoSeccion { get; set; }
    public int? OrdenDefault { get; set; }
    public bool? EsBase { get; set; }
    public bool? PuedeEliminarse { get; set; }
    public bool? PermiteReordenar { get; set; }
}


public class AgregarSeccionVersionEtRequest
{
    public int SeccionId { get; set; }
    public int? Orden { get; set; }
    public string Usuario { get; set; } = string.Empty;
}

public class AgregarSeccionVersionEtResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? VersSeccId { get; set; }
    public int? VersionId { get; set; }
    public int? SeccionId { get; set; }
    public int? Orden { get; set; }
}

public class QuitarSeccionVersionEtRequest
{
    public string Usuario { get; set; } = string.Empty;
}

public class QuitarSeccionVersionEtResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? VersSeccId { get; set; }
}

public class ReordenarSeccionesVersionEtRequest
{
    public List<ReordenarSeccionVersionEtItemRequest> Secciones { get; set; } = new();
    public string Usuario { get; set; } = string.Empty;
}

public class ReordenarSeccionVersionEtItemRequest
{
    public int VersSeccId { get; set; }
    public int Orden { get; set; }
}

public class OperacionEstructuraEtResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
}

public class GuardarContenidoSeccionEtRequest
{
    public string? Contenido { get; set; }
    public string Usuario { get; set; } = string.Empty;
}

public class GuardarContenidoSeccionEtResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? VersionSeccionContenidoId { get; set; }
    public int? VersSeccId { get; set; }
    public int? SeccionId { get; set; }
}

public class ContenidoSeccionEtDto
{
    public int VersionSeccionContenidoId { get; set; }
    public int VersSeccId { get; set; }
    public int SeccionId { get; set; }
    public string SeccionDescripcion { get; set; } = string.Empty;
    public int? IdTipoSeccion { get; set; }
    public string? Contenido { get; set; }
}

public class CambiarEstadoVersionEtRequest
{
    public string Accion { get; set; } = string.Empty;
    public string? Comentario { get; set; }
    public string Usuario { get; set; } = string.Empty;
}

public class CambiarEstadoVersionEtResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? VersionId { get; set; }
    public int? EstVerOrigenId { get; set; }
    public string? EstadoOrigen { get; set; }
    public int? EstVerDestinoId { get; set; }
    public string? EstadoDestino { get; set; }
    public string? Accion { get; set; }
    public string? Comentario { get; set; }
    public int? VersionVigenteAnteriorId { get; set; }
    public DateTime? FechaVigencia { get; set; }
}


public class VersionReemplazableEtDto
{
    public int VersionId { get; set; }
    public string DocumentoCodigo { get; set; } = string.Empty;
    public decimal VersionNumero { get; set; }
    public DateTime? VersionInicioVigencia { get; set; }
    public DateTime? VersionFinVigencia { get; set; }
    public string EstadoVersion { get; set; } = string.Empty;
}

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
    public string ProductoCodigo { get; set; } = string.Empty;
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

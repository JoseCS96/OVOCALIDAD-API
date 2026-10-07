namespace OVOCALIDAD.Application.DTOs.FichasTecnicas;

public class CrearFichaTecnicaRequest
{
    public string DocumentoCodigo { get; set; } = string.Empty;
    public string DocumentoDescripcionDocumento { get; set; } = string.Empty;
    public string? ProductoCodigo { get; set; }
    public decimal? VersionNumero { get; set; }
    public DateTime? VersionInicioVigencia { get; set; }
    public int? VersionReemplazaAId { get; set; }
    public int? VersionNroPaginas { get; set; }
    public string? VersionDescripcion { get; set; }
    public int? VersionEtOrigenId { get; set; }
    public string Usuario { get; set; } = string.Empty;
}

public class CrearFichaTecnicaResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? DocumentoId { get; set; }
    public string? DocumentoCodigo { get; set; }
    public string? DocumentoDescripcionDocumento { get; set; }
    public int? TipoDocumentoId { get; set; }
    public string? TipoDocumentoDescripcion { get; set; }
    public string? ProductoCodigo { get; set; }
    public int? VersionId { get; set; }
    public decimal? VersionNumero { get; set; }
    public int? EstVerId { get; set; }
    public string? EstadoVersion { get; set; }
    public DateTime? VersionInicioVigencia { get; set; }
    public int? VersionReemplazaAId { get; set; }
    public int? VersionNroPaginas { get; set; }
    public string? VersionDescripcion { get; set; }
    public int? VersionEtOrigenId { get; set; }
}

public class FichaTecnicaCertificadoDto
{
    public int VersionId { get; set; }
    public int DocumentoId { get; set; }
    public string DocumentoCodigo { get; set; } = string.Empty;
    public string DocumentoDescripcionDocumento { get; set; } = string.Empty;
    public string? ProductoCodigo { get; set; }
    public decimal? VersionNumero { get; set; }
    public DateTime? VersionInicioVigencia { get; set; }
    public int EstVerId { get; set; }
    public string EstadoVersion { get; set; } = string.Empty;
    public int CantidadParametrosCertificables { get; set; }
}

public class FichaTecnicaGestionDto
{
    public int VersionId { get; set; }
    public int DocumentoId { get; set; }
    public string DocumentoCodigo { get; set; } = string.Empty;
    public string DocumentoDescripcionDocumento { get; set; } = string.Empty;
    public string? ProductoCodigo { get; set; }
    public decimal? VersionNumero { get; set; }
    public DateTime? VersionInicioVigencia { get; set; }
    public int EstVerId { get; set; }
    public string EstadoVersion { get; set; } = string.Empty;
    public int? VersionNroPaginas { get; set; }
    public string? VersionDescripcion { get; set; }
    public int CantidadCaracteristicas { get; set; }
    public int CantidadParametrosCertificables { get; set; }
}


public class EliminarFichaTecnicaResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int VersionId { get; set; }
}

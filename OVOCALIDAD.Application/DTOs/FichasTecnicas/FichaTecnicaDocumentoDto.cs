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

public class SeccionFtDto
{
    public int VersionFtSeccionId { get; set; }
    public int VersionId { get; set; }
    public string Codigo { get; set; } = string.Empty;
    public string Titulo { get; set; } = string.Empty;
    public string TipoContenido { get; set; } = string.Empty;
    public int Orden { get; set; }
    public bool Visible { get; set; }
    public bool EsSistema { get; set; }
    public string? Contenido { get; set; }
}

public class GuardarContenidoSeccionFtRequest
{
    public string Titulo { get; set; } = string.Empty;
    public string? Contenido { get; set; }
    public bool Visible { get; set; } = true;
    public string Usuario { get; set; } = string.Empty;
}

public class SeccionFtOperacionResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? VersionFtSeccionId { get; set; }
    public int? VersionId { get; set; }
    public int? Orden { get; set; }
}

public class AgregarSeccionFtRequest
{
    public string Titulo { get; set; } = string.Empty;
    public string TipoContenido { get; set; } = "TEXTO";
    public int? Orden { get; set; }
    public string Usuario { get; set; } = string.Empty;
}

public class ReordenarSeccionFtItemRequest
{
    public int VersionFtSeccionId { get; set; }
    public int Orden { get; set; }
}

public class ReordenarSeccionesFtRequest
{
    public List<ReordenarSeccionFtItemRequest> Secciones { get; set; } = new();
    public string Usuario { get; set; } = string.Empty;
}

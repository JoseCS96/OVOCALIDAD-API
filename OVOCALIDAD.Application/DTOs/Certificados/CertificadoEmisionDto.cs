namespace OVOCALIDAD.Application.DTOs.Certificados;

public class CertificadoVistaDto
{
    public CertificadoCabeceraDto Cabecera { get; set; } = new();
    public List<CertificadoSeccionVistaDto> Secciones { get; set; } = new();
    public List<CertificadoResultadoVistaDto> Resultados { get; set; } = new();
}

public class CertificadoCabeceraDto
{
    public int? CertificadoId { get; set; }
    public int LoteId { get; set; }
    public string CodigoLote { get; set; } = string.Empty;
    public string ProductoCodigo { get; set; } = string.Empty;
    public string ProductoDescripcion { get; set; } = string.Empty;
    public DateTime FechaHoraProduccion { get; set; }
    public int CertificadoPlantillaId { get; set; }
    public string PlantillaNombre { get; set; } = string.Empty;
    public int VersionFtId { get; set; }
    public string DocumentoCodigo { get; set; } = string.Empty;
    public decimal? VersionNumero { get; set; }
    public string? NumeroCertificado { get; set; }
    public DateTime FechaEmision { get; set; }
    public string Estado { get; set; } = string.Empty;
}

public class CertificadoSeccionVistaDto
{
    public string TipoSeccion { get; set; } = string.Empty;
    public string? TituloSeccion { get; set; }
    public int OrdenSeccion { get; set; }
    public string? Contenido { get; set; }
}

public class CertificadoResultadoVistaDto
{
    public string TituloInforme { get; set; } = string.Empty;
    public int OrdenInforme { get; set; }
    public int OrdenDetalle { get; set; }
    public int? CaracteristicaId { get; set; }
    public string Determinacion { get; set; } = string.Empty;
    public string? Resultado { get; set; }
    public string? Especificacion { get; set; }
    public string? UnidadDeMedida { get; set; }
    public string? MetodoEnsayo { get; set; }
}

public class EmitirCertificadoRequest
{
    public int LoteId { get; set; }
    public int CertificadoPlantillaId { get; set; }
}

public class EmitirCertificadoResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int CertificadoId { get; set; }
    public string NumeroCertificado { get; set; } = string.Empty;
    public DateTime FechaEmision { get; set; }
}

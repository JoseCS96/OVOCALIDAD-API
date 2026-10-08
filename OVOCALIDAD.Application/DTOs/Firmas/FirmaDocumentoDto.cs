namespace OVOCALIDAD.Application.DTOs.Firmas;

public class FirmaDocumentoSolicitudDto
{
    public long DocumentoFirmaSolicitudId { get; set; }
    public string TipoDocumento { get; set; } = string.Empty;
    public int EntidadId { get; set; }
    public string DocumentoCodigo { get; set; } = string.Empty;
    public string DocumentoDescripcion { get; set; } = string.Empty;
    public decimal? VersionNumero { get; set; }
    public string TipoResponsabilidad { get; set; } = string.Empty;
    public string UsuarioDni { get; set; } = string.Empty;
    public string ResponsableNombre { get; set; } = string.Empty;
    public string? CargoDescripcion { get; set; }
    public string EstadoSolicitud { get; set; } = string.Empty;
    public DateTime FechaSolicitud { get; set; }
    public DateTime? FechaFirma { get; set; }
    public string? UrlDocumento { get; set; }
}

public class FirmarDocumentoRequest
{
    public string Password { get; set; } = string.Empty;
}

public class OperacionFirmaDocumentoResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public long? DocumentoFirmaSolicitudId { get; set; }
    public string? EstadoSolicitud { get; set; }
    public DateTime? FechaFirma { get; set; }
}

public class FirmaDocumentoAplicadaDto
{
    public long DocumentoFirmaSolicitudId { get; set; }
    public string TipoDocumento { get; set; } = string.Empty;
    public int EntidadId { get; set; }
    public string UsuarioDni { get; set; } = string.Empty;
    public string TipoResponsabilidad { get; set; } = string.Empty;
    public string ResponsableNombre { get; set; } = string.Empty;
    public string? CargoDescripcion { get; set; }
    public string? FirmaMimeType { get; set; }
    public byte[]? FirmaImagen { get; set; }
    public DateTime FechaFirma { get; set; }
}

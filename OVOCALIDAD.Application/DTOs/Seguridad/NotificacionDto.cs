namespace OVOCALIDAD.Application.DTOs.Seguridad;

public class NotificacionDto
{
    public long NotificacionId { get; set; }
    public string TipoNotificacion { get; set; } = string.Empty;
    public string Titulo { get; set; } = string.Empty;
    public string Mensaje { get; set; } = string.Empty;
    public string? EntidadTipo { get; set; }
    public int? EntidadId { get; set; }
    public string? UrlDestino { get; set; }
    public bool Leida { get; set; }
    public DateTime? FechaLectura { get; set; }
    public bool MostradaModal { get; set; }
    public DateTime? FechaMostradaModal { get; set; }
    public DateTime AudFechaCreacion { get; set; }
}

public class OperacionNotificacionDto
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? CantidadActualizada { get; set; }
}

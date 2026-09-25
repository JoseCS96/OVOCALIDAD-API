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
    public int CantidadVecesModal { get; set; }
    public bool Atendida { get; set; }
    public DateTime? FechaAtencion { get; set; }
    public bool MostrarCampana { get; set; }
    public bool MostrarModal { get; set; }
    public string PoliticaModal { get; set; } = string.Empty;
    public int? MaximoVecesModal { get; set; }
    public string Prioridad { get; set; } = string.Empty;
    public bool MostrarEnCampana { get; set; }
    public bool MostrarEnModal { get; set; }
    public DateTime AudFechaCreacion { get; set; }
}

public class OperacionNotificacionDto
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? CantidadActualizada { get; set; }
}

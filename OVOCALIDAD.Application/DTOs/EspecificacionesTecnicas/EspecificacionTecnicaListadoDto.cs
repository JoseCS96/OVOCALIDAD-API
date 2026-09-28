namespace OVOCALIDAD.Application.DTOs.EspecificacionesTecnicas;

public class EspecificacionTecnicaListadoDto
{
    public int VersionId { get; set; }
    public int DocumentoId { get; set; }
    public string DocumentoCodigo { get; set; } = string.Empty;
    public string DocumentoDescripcionDocumento { get; set; } = string.Empty;
    public string ProductoCodigo { get; set; } = string.Empty;
    public string? ProductoDescripcion { get; set; }
    public decimal? VersionNumero { get; set; }
    public DateTime? VersionInicioVigencia { get; set; }
    public int? VersionNroPaginas { get; set; }
    public int EstVerId { get; set; }
    public string EstadoVersion { get; set; } = string.Empty;
    public string? AudUsuarioCreacion { get; set; }
    public DateTime AudFechaCreacion { get; set; }
    public string? AudUsuarioModificacion { get; set; }
    public DateTime? AudFechaActualizacion { get; set; }
    public bool PermiteEditar { get; set; }
}

public class ListarEspecificacionesTecnicasFiltro
{
    public string? Busqueda { get; set; }
    public string? ProductoCodigo { get; set; }
    public int? EstVerId { get; set; }
}

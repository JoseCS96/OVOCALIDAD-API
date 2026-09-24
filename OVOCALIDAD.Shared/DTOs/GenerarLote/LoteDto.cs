namespace OVOCALIDAD.Shared.DTOs.GenerarLote;

public class LoteDto
{
    public int LoteId { get; set; }

    public string CodigoLote { get; set; } = string.Empty;

    public string ProductoCodigo { get; set; } = string.Empty;

    public string ProductoDescripcion { get; set; } = string.Empty;

    public int DocumentoId { get; set; }

    public string DocumentoCodigo { get; set; } = string.Empty;

    public string DocumentoDescripcionDocumento { get; set; } = string.Empty;

    public int VersionId { get; set; }

    public decimal VersionNumero { get; set; }

    public string Naturaleza { get; set; } = string.Empty;

    public string NaturalezaDescripcion { get; set; } = string.Empty;

    public string Fase { get; set; } = string.Empty;

    public string FaseDescripcion { get; set; } = string.Empty;

    public string LineaOrigen { get; set; } = string.Empty;

    public string LineaOrigenDescripcion { get; set; } = string.Empty;

    public string EstadoLote { get; set; } = string.Empty;

    public string EstadoLoteDescripcion { get; set; } = string.Empty;

    public DateTime FechaHoraProduccion { get; set; }

    public string? Observacion { get; set; }

    public string AudUsuarioCreacion { get; set; } = string.Empty;

    public DateTime AudFechaCreacion { get; set; }
}
namespace OVOCALIDAD.Application.DTOs.Lotes;

public class GenerarLoteRequest
{
    public string ProductoCodigo { get; set; } = string.Empty;

    public int NaturalezaId { get; set; }

    public int FaseId { get; set; }

    public int LineaOrigenId { get; set; }

    public string? Observacion { get; set; }

    public string Usuario { get; set; } = string.Empty;
}
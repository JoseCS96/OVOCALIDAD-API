namespace OVOCALIDAD.Application.DTOs.Lotes;

public class ProductoGenesisDto
{
    public int GenesisItemId { get; set; }
    public int Kardex { get; set; }
    public string CodigoGenesis { get; set; } = string.Empty;
    public string NombreGenesis { get; set; } = string.Empty;
    public string DescripcionGenesis { get; set; } = string.Empty;
    public int? EstadoGenesis { get; set; }
}

namespace OVOCALIDAD.Application.DTOs.Lotes;

public class CatalogosLoteDto
{
    public IReadOnlyList<ProductoCatalogoDto> Productos { get; set; } = [];
    public IReadOnlyList<CatalogoLoteDto> Naturalezas { get; set; } = [];
    public IReadOnlyList<CatalogoLoteDto> Fases { get; set; } = [];
    public IReadOnlyList<CatalogoLoteDto> LineasOrigen { get; set; } = [];
}

public class ProductoCatalogoDto
{
    public string Codigo { get; set; } = string.Empty;
    public string Descripcion { get; set; } = string.Empty;
}

public class CatalogoLoteDto
{
    public int Id { get; set; }
    public string Codigo { get; set; } = string.Empty;
    public string Descripcion { get; set; } = string.Empty;
}

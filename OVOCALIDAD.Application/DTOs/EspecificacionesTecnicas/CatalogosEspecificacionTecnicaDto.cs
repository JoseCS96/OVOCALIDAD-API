namespace OVOCALIDAD.Application.DTOs.EspecificacionesTecnicas;

public class CatalogosEspecificacionTecnicaDto
{
    public IReadOnlyList<ProductoEtCatalogoDto> Productos { get; set; } = [];
    public IReadOnlyList<TipoCaracteristicaEtCatalogoDto> TiposCaracteristica { get; set; } = [];
    public IReadOnlyList<MetodoEnsayoEtCatalogoDto> MetodosEnsayo { get; set; } = [];
    public IReadOnlyList<CaracteristicaEtCatalogoDto> Caracteristicas { get; set; } = [];
    public IReadOnlyList<TipoCriterioEtCatalogoDto> TiposCriterio { get; set; } = [];
    public IReadOnlyList<FaseEtCatalogoDto> Fases { get; set; } = [];
}

public class ProductoEtCatalogoDto
{
    public string ProductoCodigo { get; set; } = string.Empty;
    public string ProductoDescripcion { get; set; } = string.Empty;
}

public class TipoCaracteristicaEtCatalogoDto
{
    public int TipoCaractId { get; set; }
    public string TipoCaractDescripcion { get; set; } = string.Empty;
}

public class MetodoEnsayoEtCatalogoDto
{
    public int MetEnsayoId { get; set; }
    public string MetEnsayoDescripcion { get; set; } = string.Empty;
}

public class CaracteristicaEtCatalogoDto
{
    public int CaracteristicaId { get; set; }
    public string CaracteristicaDescripcion { get; set; } = string.Empty;
    public string? Unidad { get; set; }
    public int TipoCaractId { get; set; }
    public string TipoCaracteristica { get; set; } = string.Empty;
    public int? MetEnsayoId { get; set; }
    public string? MetodoEnsayo { get; set; }
}

public class TipoCriterioEtCatalogoDto
{
    public int TipoCriterioId { get; set; }
    public string TipoCriterio { get; set; } = string.Empty;
}

public class FaseEtCatalogoDto
{
    public int FaseId { get; set; }
    public string FaseCodigo { get; set; } = string.Empty;
    public string FaseDescripcion { get; set; } = string.Empty;
    public string Estado { get; set; } = string.Empty;
}

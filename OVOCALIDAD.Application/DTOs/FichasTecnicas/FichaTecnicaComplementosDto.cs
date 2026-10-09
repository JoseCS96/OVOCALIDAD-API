namespace OVOCALIDAD.Application.DTOs.FichasTecnicas;

public class DeclaracionFtDto
{
    public int VersionFtDeclaracionId { get; set; }
    public int VersionId { get; set; }
    public string Codigo { get; set; } = string.Empty;
    public string Titulo { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
    public int Orden { get; set; }
    public bool Estado { get; set; }
}

public class GuardarDeclaracionFtItemRequest
{
    public string Codigo { get; set; } = string.Empty;
    public string Titulo { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
    public int Orden { get; set; }
}

public class GuardarDeclaracionesFtRequest
{
    public List<GuardarDeclaracionFtItemRequest> Declaraciones { get; set; } = new();
    public string Usuario { get; set; } = string.Empty;
}

public class AlergenoFtDto
{
    public int AlergenoId { get; set; }
    public string AlergenoCodigo { get; set; } = string.Empty;
    public string AlergenoDescripcion { get; set; } = string.Empty;
    public int Orden { get; set; }
    public bool EnProducto { get; set; }
    public bool EnLinea { get; set; }
    public bool EnPlanta { get; set; }
    public string? Descripcion { get; set; }
}

public class GuardarAlergenoFtItemRequest
{
    public int AlergenoId { get; set; }
    public bool EnProducto { get; set; }
    public bool EnLinea { get; set; }
    public bool EnPlanta { get; set; }
    public string? Descripcion { get; set; }
    public int Orden { get; set; }
}

public class GuardarAlergenosFtRequest
{
    public List<GuardarAlergenoFtItemRequest> Alergenos { get; set; } = new();
    public string Usuario { get; set; } = string.Empty;
}

public class GrupoCaracteristicaFtDto
{
    public int TipoCaractId { get; set; }
    public string TipoCaractDescripcion { get; set; } = string.Empty;
    public int? VersionFtCaracteristicaGrupoId { get; set; }
    public string Titulo { get; set; } = string.Empty;
    public string? Referencia { get; set; }
    public string? Nota { get; set; }
    public int? Orden { get; set; }
}

public class GuardarGrupoCaracteristicaFtRequest
{
    public string? Titulo { get; set; }
    public string? Referencia { get; set; }
    public string? Nota { get; set; }
    public int? Orden { get; set; }
    public string Usuario { get; set; } = string.Empty;
}

public class OperacionComplementoFtResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int? VersionId { get; set; }
    public int? Cantidad { get; set; }
    public int? TipoCaractId { get; set; }
}

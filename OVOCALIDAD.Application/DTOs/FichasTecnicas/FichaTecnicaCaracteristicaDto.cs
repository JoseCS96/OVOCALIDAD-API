namespace OVOCALIDAD.Application.DTOs.FichasTecnicas;

public class FichaTecnicaCaracteristicaDto
{
    public int VersionFtCaracteristicaId { get; set; }
    public int VersionId { get; set; }
    public int CaracteristicaId { get; set; }
    public string CaracteristicaDescripcion { get; set; } = string.Empty;
    public int? TipoCaractId { get; set; }
    public string? TipoCaractDescripcion { get; set; }
    public int TipoCriterioId { get; set; }
    public decimal? ValorCuantitativoInicial { get; set; }
    public decimal? ValorCuantitativoFinal { get; set; }
    public decimal? ValorCuantitativoIgual { get; set; }
    public string? ValorCualitativo { get; set; }
    public string? UnidadDeMedida { get; set; }
    public int? MetEnsayoId { get; set; }
    public string? MetEnsayoDescripcion { get; set; }
    public bool ImprimeCertificado { get; set; }
    public bool ObligatorioCertificado { get; set; }
    public int? OrdenCertificado { get; set; }
    public bool Estado { get; set; }
}

public class ConfiguracionCertificadoFtDto
{
    public int VersionFtCaracteristicaId { get; set; }
    public int VersionId { get; set; }
    public int CaracteristicaId { get; set; }
    public string Determinacion { get; set; } = string.Empty;
    public int? TipoCaractId { get; set; }
    public string? TipoCaractDescripcion { get; set; }
    public int TipoCriterioId { get; set; }
    public decimal? ValorCuantitativoInicial { get; set; }
    public decimal? ValorCuantitativoFinal { get; set; }
    public decimal? ValorCuantitativoIgual { get; set; }
    public string? ValorCualitativo { get; set; }
    public string? UnidadDeMedida { get; set; }
    public int? MetEnsayoId { get; set; }
    public string? MetEnsayoDescripcion { get; set; }
    public bool ObligatorioCertificado { get; set; }
    public int OrdenCertificado { get; set; }
}

public class GuardarCaracteristicaFtRequest
{
    public int? VersionFtCaracteristicaId { get; set; }
    public int CaracteristicaId { get; set; }
    public int TipoCriterioId { get; set; }
    public decimal? ValorCuantitativoInicial { get; set; }
    public decimal? ValorCuantitativoFinal { get; set; }
    public decimal? ValorCuantitativoIgual { get; set; }
    public string? ValorCualitativo { get; set; }
    public string? UnidadDeMedida { get; set; }
    public bool ImprimeCertificado { get; set; }
    public bool ObligatorioCertificado { get; set; }
    public int? OrdenCertificado { get; set; }
    public string Usuario { get; set; } = string.Empty;
}

public class GuardarCaracteristicaFtResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int VersionFtCaracteristicaId { get; set; }
}

public class EliminarCaracteristicaFtResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int VersionFtCaracteristicaId { get; set; }
}

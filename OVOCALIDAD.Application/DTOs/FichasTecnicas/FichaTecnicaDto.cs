namespace OVOCALIDAD.Application.DTOs.FichasTecnicas;

public class SeccionFichaTecnicaDto
{
    public int VersionFtSeccionId { get; set; }
    public int VersionId { get; set; }
    public string Codigo { get; set; } = "";
    public string Titulo { get; set; } = "";
    public string TipoContenido { get; set; } = "";
    public int Orden { get; set; }
    public bool Visible { get; set; }
    public bool EsSistema { get; set; }
    public string? Contenido { get; set; }
}

public class CaracteristicaFichaTecnicaDto
{
    public int CodigoResultado { get; set; }
    public int VersionFtCaracteristicaId { get; set; }
    public int VersionFtId { get; set; }
    public int? VersCaractOrigenId { get; set; }
    public int? OrdenTecnico { get; set; }
    public int? FaseId { get; set; }
    public string? FaseCodigo { get; set; }
    public string? FaseDescripcion { get; set; }
    public int? VersionFaseId { get; set; }
    public int? VersionFaseOrden { get; set; }
    public int? TipoCaractId { get; set; }
    public string? TipoCaracteristicaDescripcion { get; set; }
    public int CaracteristicaId { get; set; }
    public string CaracteristicaDescripcion { get; set; } = "";
    public string? UnidadCatalogo { get; set; }
    public string? UnidadDeMedida { get; set; }
    public int TipoCriterioId { get; set; }
    public string? TipoCriterioDescripcion { get; set; }
    public decimal? ValorCuantitativoInicial { get; set; }
    public decimal? ValorCuantitativoFinal { get; set; }
    public decimal? ValorCuantitativoIgual { get; set; }
    public string? ValorCualitativo { get; set; }
    public string? CriterioMostrar { get; set; }
    public int? MetEnsayoId { get; set; }
    public string? MetodoEnsayoDescripcion { get; set; }
    public bool ImprimeCertificado { get; set; }
    public bool ObligatorioCertificado { get; set; }
    public int? OrdenCertificado { get; set; }
}

public class OperacionFichaTecnicaResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = "";
    public int? VersionFtSeccionId { get; set; }
    public int? VersionFtCaracteristicaId { get; set; }
    public int? VersionId { get; set; }
    public int? VersionFtId { get; set; }
}

public class GuardarSeccionFichaTecnicaRequest
{
    public string Titulo { get; set; } = "";
    public string? Contenido { get; set; }
    public bool Visible { get; set; } = true;
    public string Usuario { get; set; } = "";
}

public class AgregarSeccionFichaTecnicaRequest
{
    public string Titulo { get; set; } = "";
    public string TipoContenido { get; set; } = "TEXTO";
    public int? Orden { get; set; }
    public string Usuario { get; set; } = "";
}

public class QuitarSeccionFichaTecnicaRequest
{
    public string Usuario { get; set; } = "";
}

public class ReordenarSeccionesFichaTecnicaRequest
{
    public IReadOnlyList<OrdenSeccionFichaTecnicaDto> Secciones { get; set; } = [];
    public string Usuario { get; set; } = "";
}

public class OrdenSeccionFichaTecnicaDto
{
    public int VersionFtSeccionId { get; set; }
    public int Orden { get; set; }
}

public class GuardarCaracteristicaFichaTecnicaRequest
{
    public int TipoCriterioId { get; set; }
    public decimal? ValorCuantitativoInicial { get; set; }
    public decimal? ValorCuantitativoFinal { get; set; }
    public decimal? ValorCuantitativoIgual { get; set; }
    public string? ValorCualitativo { get; set; }
    public string? UnidadDeMedida { get; set; }
    public bool ImprimeCertificado { get; set; }
    public bool ObligatorioCertificado { get; set; }
    public int? OrdenCertificado { get; set; }
    public string Usuario { get; set; } = "";
}

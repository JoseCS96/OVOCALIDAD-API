namespace OVOCALIDAD.Application.DTOs.Certificados;

public class CrearPlantillaCertificadoRequest
{
    public int VersionFtId { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
    public string Usuario { get; set; } = string.Empty;
}
public class PlantillaCertificadoOperacionResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int CertificadoPlantillaId { get; set; }
}
public class PlantillaCertificadoListaDto
{
    public int CertificadoPlantillaId { get; set; }
    public int VersionFtId { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
    public int DocumentoId { get; set; }
    public string DocumentoCodigo { get; set; } = string.Empty;
    public string DocumentoDescripcionDocumento { get; set; } = string.Empty;
    public string? ProductoCodigo { get; set; }
    public decimal? VersionNumero { get; set; }
    public int EstVerId { get; set; }
    public string AudUsuarioCreacion { get; set; } = string.Empty;
    public DateTime AudFechaCreacion { get; set; }
    public int CantidadSecciones { get; set; }
    public int CantidadCaracteristicas { get; set; }
}
public class PlantillaCertificadoDto
{
    public int CertificadoPlantillaId { get; set; }
    public int VersionFtId { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
    public string DocumentoCodigo { get; set; } = string.Empty;
    public string DocumentoDescripcionDocumento { get; set; } = string.Empty;
    public string? ProductoCodigo { get; set; }
    public decimal? VersionNumero { get; set; }
    public int EstVerId { get; set; }
    public string EstadoVersionFt { get; set; } = string.Empty;
    public List<PlantillaCertificadoSeccionDto> Secciones { get; set; } = new();
    public List<PlantillaCertificadoCaracteristicaDto> Caracteristicas { get; set; } = new();
}
public class PlantillaCertificadoSeccionDto
{
    public int CertificadoPlantillaSeccionId { get; set; }
    public int CertificadoPlantillaId { get; set; }
    public string TipoSeccion { get; set; } = string.Empty;
    public string? Titulo { get; set; }
    public int Orden { get; set; }
    public bool Visible { get; set; }
    public string ModoSeleccion { get; set; } = "MANUAL";
    public int? VersionFaseId { get; set; }
    public int? FaseId { get; set; }
    public string? FaseCodigo { get; set; }
    public string? FaseDescripcion { get; set; }
    public int? TipoCaractId { get; set; }
    public string? TipoCaractDescripcion { get; set; }
}
public class PlantillaCertificadoCaracteristicaDto
{
    public int CertificadoPlantillaCaracteristicaId { get; set; }
    public int CertificadoPlantillaSeccionId { get; set; }
    public int VersionFtCaracteristicaId { get; set; }
    public int CaracteristicaId { get; set; }
    public string Determinacion { get; set; } = string.Empty;
    public int? TipoCaractId { get; set; }
    public string? TipoCaractDescripcion { get; set; }
    public int? FaseId { get; set; }
    public int? VersionFaseId { get; set; }
    public string? FaseCodigo { get; set; }
    public string? FaseDescripcion { get; set; }
    public int TipoCriterioId { get; set; }
    public decimal? ValorCuantitativoInicial { get; set; }
    public decimal? ValorCuantitativoFinal { get; set; }
    public decimal? ValorCuantitativoIgual { get; set; }
    public string? ValorCualitativo { get; set; }
    public string? UnidadDeMedida { get; set; }
    public string? MetEnsayoDescripcion { get; set; }
    public bool ObligatorioCertificado { get; set; }
    public int Orden { get; set; }
}
public class GuardarDisenoPlantillaCertificadoRequest
{
    public List<GuardarPlantillaSeccionRequest> Secciones { get; set; } = new();
    public string Usuario { get; set; } = string.Empty;
}
public class GuardarPlantillaSeccionRequest
{
    public string TipoSeccion { get; set; } = string.Empty;
    public string? Titulo { get; set; }
    public int Orden { get; set; }
    public bool Visible { get; set; } = true;
    public string ModoSeleccion { get; set; } = "MANUAL";
    public int? VersionFaseId { get; set; }
    public int? TipoCaractId { get; set; }
    public List<GuardarPlantillaCaracteristicaRequest> Caracteristicas { get; set; } = new();
}
public class GuardarPlantillaCaracteristicaRequest
{
    public int VersionFtCaracteristicaId { get; set; }
    public int Orden { get; set; }
}

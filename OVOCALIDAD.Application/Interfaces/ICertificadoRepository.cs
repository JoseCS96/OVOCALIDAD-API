using OVOCALIDAD.Application.DTOs.Certificados;
namespace OVOCALIDAD.Application.Interfaces;
public interface ICertificadoRepository
{
    Task<PlantillaCertificadoOperacionResponse> CrearPlantillaAsync(CrearPlantillaCertificadoRequest request);
    Task<IReadOnlyList<PlantillaCertificadoListaDto>> ListarPlantillasAsync(int? versionFtId, string? productoCodigo);
    Task<PlantillaCertificadoDto?> ObtenerPlantillaAsync(int id);
    Task<PlantillaCertificadoOperacionResponse> GuardarDisenoAsync(int id, GuardarDisenoPlantillaCertificadoRequest request);
    Task<PlantillaCertificadoOperacionResponse> EliminarPlantillaAsync(int id, string usuario);
    Task<CertificadoEmpresaDto?> ObtenerEmpresaAsync();
    Task<GuardarCertificadoEmpresaResponse> GuardarEmpresaAsync(GuardarCertificadoEmpresaRequest request);
}
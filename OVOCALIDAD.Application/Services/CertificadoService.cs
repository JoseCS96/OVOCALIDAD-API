using OVOCALIDAD.Application.DTOs.Certificados;
using OVOCALIDAD.Application.Interfaces;
namespace OVOCALIDAD.Application.Services;
public class CertificadoService : ICertificadoService
{
    private readonly ICertificadoRepository _repository;
    public CertificadoService(ICertificadoRepository repository) => _repository = repository;
    public Task<PlantillaCertificadoOperacionResponse> CrearPlantillaAsync(CrearPlantillaCertificadoRequest r) => _repository.CrearPlantillaAsync(r);
    public Task<IReadOnlyList<PlantillaCertificadoListaDto>> ListarPlantillasAsync(int? v,string? p) => _repository.ListarPlantillasAsync(v,p);
    public Task<PlantillaCertificadoDto?> ObtenerPlantillaAsync(int id) => _repository.ObtenerPlantillaAsync(id);
    public Task<PlantillaCertificadoOperacionResponse> GuardarDisenoAsync(int id, GuardarDisenoPlantillaCertificadoRequest r) => _repository.GuardarDisenoAsync(id,r);
    public Task<PlantillaCertificadoOperacionResponse> EliminarPlantillaAsync(int id,string u) => _repository.EliminarPlantillaAsync(id,u);
    public Task<CertificadoEmpresaDto?> ObtenerEmpresaAsync() => _repository.ObtenerEmpresaAsync();
    public Task<GuardarCertificadoEmpresaResponse> GuardarEmpresaAsync(GuardarCertificadoEmpresaRequest r) => _repository.GuardarEmpresaAsync(r);
}
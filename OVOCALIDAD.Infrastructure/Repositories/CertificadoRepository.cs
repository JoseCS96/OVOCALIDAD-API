using OVOCALIDAD.Application.DTOs.Certificados;
using OVOCALIDAD.Application.Interfaces;
using OVOCALIDAD.Infrastructure.StoredProcedures;
namespace OVOCALIDAD.Infrastructure.Repositories;
public class CertificadoRepository : ICertificadoRepository
{
    private readonly CertificadoStoredProcedure _sp;
    public CertificadoRepository(CertificadoStoredProcedure sp) => _sp = sp;
    public Task<PlantillaCertificadoOperacionResponse> CrearPlantillaAsync(CrearPlantillaCertificadoRequest r) => _sp.CrearPlantillaAsync(r);
    public Task<IReadOnlyList<PlantillaCertificadoListaDto>> ListarPlantillasAsync(int? v, string? p) => _sp.ListarPlantillasAsync(v,p);
    public Task<PlantillaCertificadoDto?> ObtenerPlantillaAsync(int id) => _sp.ObtenerPlantillaAsync(id);
    public Task<PlantillaCertificadoOperacionResponse> GuardarDisenoAsync(int id, GuardarDisenoPlantillaCertificadoRequest r) => _sp.GuardarDisenoAsync(id,r);
    public Task<PlantillaCertificadoOperacionResponse> EliminarPlantillaAsync(int id,string u) => _sp.EliminarPlantillaAsync(id,u);
    public Task<CertificadoEmpresaDto?> ObtenerEmpresaAsync() => _sp.ObtenerEmpresaAsync();
    public Task<GuardarCertificadoEmpresaResponse> GuardarEmpresaAsync(GuardarCertificadoEmpresaRequest r) => _sp.GuardarEmpresaAsync(r);
    public Task<CertificadoVistaDto?> PrevisualizarAsync(int loteId, int certificadoPlantillaId)
        => _sp.PrevisualizarAsync(loteId, certificadoPlantillaId);

    public Task<EmitirCertificadoResponse> EmitirAsync(EmitirCertificadoRequest request, string usuario)
        => _sp.EmitirAsync(request, usuario);

    public Task<CertificadoVistaDto?> ObtenerEmitidoAsync(int certificadoId)
        => _sp.ObtenerEmitidoAsync(certificadoId);
}

using OVOCALIDAD.Application.DTOs.EspecificacionesTecnicas;
using OVOCALIDAD.Infrastructure.Mappers;
using SPNames = OVOCALIDAD.Shared.Constants.StoredProcedures;

namespace OVOCALIDAD.Infrastructure.StoredProcedures;

public class EspecificacionTecnicaStoredProcedure
{
    private readonly StoredProcedureExecutor _executor;

    public EspecificacionTecnicaStoredProcedure(StoredProcedureExecutor executor)
    {
        _executor = executor;
    }

    public async Task<CatalogosEspecificacionTecnicaDto> ObtenerCatalogosAsync()
    {
        using var reader = await _executor.ExecuteReaderAsync(
            SPNames.SP_OBTENER_CATALOGOS_ET);

        var productos = new List<ProductoEtCatalogoDto>();
        while (await reader.ReadAsync())
            productos.Add(reader.MapTo<ProductoEtCatalogoDto>());

        var tiposCaracteristica = new List<TipoCaracteristicaEtCatalogoDto>();
        if (await reader.NextResultAsync())
            while (await reader.ReadAsync())
                tiposCaracteristica.Add(reader.MapTo<TipoCaracteristicaEtCatalogoDto>());

        var metodosEnsayo = new List<MetodoEnsayoEtCatalogoDto>();
        if (await reader.NextResultAsync())
            while (await reader.ReadAsync())
                metodosEnsayo.Add(reader.MapTo<MetodoEnsayoEtCatalogoDto>());

        var caracteristicas = new List<CaracteristicaEtCatalogoDto>();
        if (await reader.NextResultAsync())
            while (await reader.ReadAsync())
                caracteristicas.Add(reader.MapTo<CaracteristicaEtCatalogoDto>());

        var tiposCriterio = new List<TipoCriterioEtCatalogoDto>();
        if (await reader.NextResultAsync())
            while (await reader.ReadAsync())
                tiposCriterio.Add(reader.MapTo<TipoCriterioEtCatalogoDto>());

        var fases = new List<FaseEtCatalogoDto>();
        if (await reader.NextResultAsync())
            while (await reader.ReadAsync())
                fases.Add(reader.MapTo<FaseEtCatalogoDto>());

        return new CatalogosEspecificacionTecnicaDto
        {
            Productos = productos,
            TiposCaracteristica = tiposCaracteristica,
            MetodosEnsayo = metodosEnsayo,
            Caracteristicas = caracteristicas,
            TiposCriterio = tiposCriterio,
            Fases = fases
        };
    }
}

using Microsoft.Data.SqlClient;
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

    public async Task<DetalleEspecificacionTecnicaDto?> ObtenerDetalleAsync(int versionId)
    {
        var parametros = new List<SqlParameter>
        {
            new("@VersionId", versionId)
        };

        using var reader = await _executor.ExecuteReaderAsync(
            SPNames.SP_OBTENER_ESPECIFICACION_TECNICA,
            parametros);

        if (!await reader.ReadAsync())
            return null;

        var informacionGeneral = reader.MapTo<InformacionGeneralEtDto>();

        if (informacionGeneral.CodigoResultado != 0)
            return null;

        var secciones = new List<SeccionEtDto>();
        if (await reader.NextResultAsync())
            while (await reader.ReadAsync())
                secciones.Add(reader.MapTo<SeccionEtDto>());

        var responsables = new List<ResponsableEtDto>();
        if (await reader.NextResultAsync())
            while (await reader.ReadAsync())
                responsables.Add(reader.MapTo<ResponsableEtDto>());

        var ingredientes = new List<IngredienteEtDto>();
        if (await reader.NextResultAsync())
            while (await reader.ReadAsync())
                ingredientes.Add(reader.MapTo<IngredienteEtDto>());

        var recetas = new List<RecetaEtDto>();
        if (await reader.NextResultAsync())
            while (await reader.ReadAsync())
                recetas.Add(reader.MapTo<RecetaEtDto>());

        var procedimientos = new List<ProcedimientoEtDto>();
        if (await reader.NextResultAsync())
            while (await reader.ReadAsync())
                procedimientos.Add(reader.MapTo<ProcedimientoEtDto>());

        var tratamientos = new List<TratamientoEtDto>();
        if (await reader.NextResultAsync())
            while (await reader.ReadAsync())
                tratamientos.Add(reader.MapTo<TratamientoEtDto>());

        var parametrosTratamiento = new List<ParametroTratamientoEtDto>();
        if (await reader.NextResultAsync())
            while (await reader.ReadAsync())
                parametrosTratamiento.Add(reader.MapTo<ParametroTratamientoEtDto>());

        var caracteristicas = new List<CaracteristicaVersionEtDto>();
        if (await reader.NextResultAsync())
            while (await reader.ReadAsync())
                caracteristicas.Add(reader.MapTo<CaracteristicaVersionEtDto>());

        var instrucciones = new List<InstruccionEtDto>();
        if (await reader.NextResultAsync())
            while (await reader.ReadAsync())
                instrucciones.Add(reader.MapTo<InstruccionEtDto>());

        var contenidoRotulado = new List<ContenidoRotuladoEtDto>();
        if (await reader.NextResultAsync())
            while (await reader.ReadAsync())
                contenidoRotulado.Add(reader.MapTo<ContenidoRotuladoEtDto>());

        var cambiosVersion = new List<CambioVersionEtDto>();
        if (await reader.NextResultAsync())
            while (await reader.ReadAsync())
                cambiosVersion.Add(reader.MapTo<CambioVersionEtDto>());

        var anexos = new List<AnexoEtDto>();
        if (await reader.NextResultAsync())
            while (await reader.ReadAsync())
                anexos.Add(reader.MapTo<AnexoEtDto>());

        var historial = new List<HistorialEstadoEtDto>();
        if (await reader.NextResultAsync())
            while (await reader.ReadAsync())
                historial.Add(reader.MapTo<HistorialEstadoEtDto>());

        return new DetalleEspecificacionTecnicaDto
        {
            InformacionGeneral = informacionGeneral,
            Secciones = secciones,
            Responsables = responsables,
            Ingredientes = ingredientes,
            Recetas = recetas,
            Procedimientos = procedimientos,
            Tratamientos = tratamientos,
            ParametrosTratamiento = parametrosTratamiento,
            Caracteristicas = caracteristicas,
            Instrucciones = instrucciones,
            ContenidoRotulado = contenidoRotulado,
            CambiosVersion = cambiosVersion,
            Anexos = anexos,
            Historial = historial
        };
    }

}

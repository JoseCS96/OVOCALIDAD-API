using System.Text.Json;
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

    public async Task<CrearEspecificacionTecnicaResponse> CrearAsync(CrearEspecificacionTecnicaRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@DocumentoCodigo", request.DocumentoCodigo),
            new("@DocumentoDescripcionDocumento", request.DocumentoDescripcionDocumento),
            new("@ProductoCodigo", request.ProductoCodigo),
            new("@PresentacionesGenesisJson", JsonSerializer.Serialize(request.PresentacionesGenesis, new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase })),
            new("@VersionNumero", request.VersionNumero),
            new("@VersionInicioVigencia", (object?)request.VersionInicioVigencia?.Date ?? DBNull.Value),
            new("@VersionReemplazaAId", (object?)request.VersionReemplazaAId ?? DBNull.Value),
            new("@VersionNroPaginas", (object?)request.VersionNroPaginas ?? DBNull.Value),
            new("@SeccionesJson", JsonSerializer.Serialize(request.Secciones, new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase })),
            new("@Usuario", request.Usuario)
        };

        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_CREAR_ESPECIFICACION_TECNICA, parametros);
        return await reader.ReadAsync() ? reader.MapTo<CrearEspecificacionTecnicaResponse>() : new CrearEspecificacionTecnicaResponse
        {
            CodigoResultado = -1,
            Mensaje = "El procedimiento no devolvió resultado."
        };
    }

    public async Task<CatalogosEspecificacionTecnicaDto> ObtenerCatalogosAsync()
    {
        using var reader = await _executor.ExecuteReaderAsync(
            SPNames.SP_OBTENER_CATALOGOS_ET);

        var tiposCaracteristica = new List<TipoCaracteristicaEtCatalogoDto>();
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
            TiposCaracteristica = tiposCaracteristica,
            MetodosEnsayo = metodosEnsayo,
            Caracteristicas = caracteristicas,
            TiposCriterio = tiposCriterio,
            Fases = fases
        };
    }

    public async Task<SeccionesEtCatalogoDto> ObtenerSeccionesAsync()
    {
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_OBTENER_SECCIONES_ET);

        var secciones = new List<SeccionDisponibleEtDto>();
        while (await reader.ReadAsync())
            secciones.Add(reader.MapTo<SeccionDisponibleEtDto>());

        var tipos = new List<TipoSeccionEtDto>();
        if (await reader.NextResultAsync())
            while (await reader.ReadAsync())
                tipos.Add(reader.MapTo<TipoSeccionEtDto>());

        return new SeccionesEtCatalogoDto { Secciones = secciones, TiposSeccion = tipos };
    }

    public async Task<CrearSeccionEtResponse> CrearSeccionAsync(CrearSeccionEtRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@SeccionDescripcion", request.SeccionDescripcion),
            new("@IdTipoSeccion", request.IdTipoSeccion),
            new("@Usuario", request.Usuario)
        };

        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_CREAR_SECCION_ET, parametros);
        return await reader.ReadAsync() ? reader.MapTo<CrearSeccionEtResponse>() : new CrearSeccionEtResponse
        {
            CodigoResultado = -1,
            Mensaje = "El procedimiento no devolvió resultado."
        };
    }

    public async Task<AgregarSeccionVersionEtResponse> AgregarSeccionVersionAsync(int versionId, AgregarSeccionVersionEtRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@VersionId", versionId),
            new("@SeccionId", request.SeccionId),
            new("@Orden", (object?)request.Orden ?? DBNull.Value),
            new("@Usuario", request.Usuario)
        };

        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_AGREGAR_SECCION_VERSION_ET, parametros);
        return await reader.ReadAsync() ? reader.MapTo<AgregarSeccionVersionEtResponse>() : new AgregarSeccionVersionEtResponse
        {
            CodigoResultado = -1,
            Mensaje = "El procedimiento no devolvió resultado."
        };
    }

    public async Task<QuitarSeccionVersionEtResponse> QuitarSeccionVersionAsync(int versionId, int versSeccId, QuitarSeccionVersionEtRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@VersionId", versionId),
            new("@VersSeccId", versSeccId),
            new("@Usuario", request.Usuario)
        };

        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_QUITAR_SECCION_VERSION_ET, parametros);
        return await reader.ReadAsync() ? reader.MapTo<QuitarSeccionVersionEtResponse>() : new QuitarSeccionVersionEtResponse
        {
            CodigoResultado = -1,
            Mensaje = "El procedimiento no devolvió resultado."
        };
    }

    public async Task<OperacionEstructuraEtResponse> ReordenarSeccionesVersionAsync(int versionId, ReordenarSeccionesVersionEtRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@VersionId", versionId),
            new("@SeccionesJson", JsonSerializer.Serialize(request.Secciones, new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase })),
            new("@Usuario", request.Usuario)
        };

        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_REORDENAR_SECCIONES_VERSION_ET, parametros);
        return await reader.ReadAsync() ? reader.MapTo<OperacionEstructuraEtResponse>() : new OperacionEstructuraEtResponse
        {
            CodigoResultado = -1,
            Mensaje = "El procedimiento no devolvió resultado."
        };
    }

    public async Task<GuardarContenidoSeccionEtResponse> GuardarContenidoSeccionAsync(int versionId, int versSeccId, GuardarContenidoSeccionEtRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@VersionId", versionId),
            new("@VersSeccId", versSeccId),
            new("@Contenido", (object?)request.Contenido ?? DBNull.Value),
            new("@Usuario", request.Usuario)
        };

        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_GUARDAR_CONTENIDO_SECCION_ET, parametros);
        return await reader.ReadAsync() ? reader.MapTo<GuardarContenidoSeccionEtResponse>() : new GuardarContenidoSeccionEtResponse
        {
            CodigoResultado = -1,
            Mensaje = "El procedimiento no devolvió resultado."
        };
    }

    public async Task<IReadOnlyList<ContenidoSeccionEtDto>> ObtenerContenidoSeccionesAsync(int versionId)
    {
        var parametros = new List<SqlParameter> { new("@VersionId", versionId) };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_OBTENER_CONTENIDO_SECCIONES_ET, parametros);
        var items = new List<ContenidoSeccionEtDto>();
        while (await reader.ReadAsync())
            items.Add(reader.MapTo<ContenidoSeccionEtDto>());
        return items;
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

        var presentacionesGenesis = new List<PresentacionGenesisEtDto>();
        if (await reader.NextResultAsync())
            while (await reader.ReadAsync())
                presentacionesGenesis.Add(reader.MapTo<PresentacionGenesisEtDto>());

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
            Historial = historial,
            PresentacionesGenesis = presentacionesGenesis
        };
    }


    public async Task<IReadOnlyList<VersionReemplazableEtDto>> ObtenerVersionesReemplazablesAsync(int versionId)
    {
        var parametros = new List<SqlParameter> { new("@VersionId", versionId) };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_OBTENER_VERSIONES_REEMPLAZABLES_ET, parametros);
        var items = new List<VersionReemplazableEtDto>();
        while (await reader.ReadAsync())
            items.Add(reader.MapTo<VersionReemplazableEtDto>());
        return items;
    }

    public async Task<OperacionEstructuraEtResponse> VincularPdfAsync(int versionId, string nombre, string ruta, string usuario)
    {
        var parametros = new List<SqlParameter>
        {
            new("@VersionId", versionId),
            new("@ArchivoOriginalNombre", nombre),
            new("@ArchivoOriginalRuta", ruta),
            new("@Usuario", usuario)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_VINCULAR_PDF_ET, parametros);
        return await reader.ReadAsync() ? reader.MapTo<OperacionEstructuraEtResponse>() : new OperacionEstructuraEtResponse
        {
            CodigoResultado = -1,
            Mensaje = "El procedimiento no devolvió resultado."
        };
    }

    public async Task<GuardarInformacionGeneralEtResponse> GuardarInformacionGeneralAsync(int versionId, GuardarInformacionGeneralEtRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@VersionId", versionId),
            new("@DocumentoDescripcionDocumento", request.DocumentoDescripcionDocumento),
            new("@VersionNumero", (object?)request.VersionNumero ?? DBNull.Value),
            new("@VersionInicioVigencia", (object?)request.VersionInicioVigencia?.Date ?? DBNull.Value),
            new("@VersionReemplazaAId", (object?)request.VersionReemplazaAId ?? DBNull.Value),
            new("@VersionNroPaginas", (object?)request.VersionNroPaginas ?? DBNull.Value),
            new("@VersionDescripcion", (object?)request.VersionDescripcion ?? DBNull.Value),
            new("@Usuario", request.Usuario)
        };

        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_GUARDAR_INFORMACION_GENERAL_ET, parametros);
        return await reader.ReadAsync() ? reader.MapTo<GuardarInformacionGeneralEtResponse>() : new GuardarInformacionGeneralEtResponse
        {
            CodigoResultado = -1,
            Mensaje = "El procedimiento no devolvió resultado."
        };
    }

    public async Task<GuardarContenidoBaseEtResponse> GuardarContenidoBaseAsync(int versionId, GuardarContenidoBaseEtRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@VersionId", versionId),
            new("@TipoContenido", request.TipoContenido),
            new("@Contenido", (object?)request.Contenido ?? DBNull.Value),
            new("@Usuario", request.Usuario)
        };

        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_GUARDAR_CONTENIDO_BASE_ET, parametros);
        return await reader.ReadAsync() ? reader.MapTo<GuardarContenidoBaseEtResponse>() : new GuardarContenidoBaseEtResponse
        {
            CodigoResultado = -1,
            Mensaje = "El procedimiento no devolvió resultado."
        };
    }

    public async Task<IReadOnlyList<ResponsableEtCatalogoDto>> ObtenerResponsablesAsync()
    {
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_OBTENER_RESPONSABLES_ET);
        var items = new List<ResponsableEtCatalogoDto>();
        while (await reader.ReadAsync()) items.Add(reader.MapTo<ResponsableEtCatalogoDto>());
        return items;
    }

    public async Task<GuardarResponsablesEtResponse> GuardarResponsablesAsync(int versionId, GuardarResponsablesEtRequest request)
    {
        var payload = new
        {
            elaboradoPor = request.ElaboradoPor,
            revisadoPor = request.RevisadoPor,
            aprobadoPor = request.AprobadoPor
        };
        var parametros = new List<SqlParameter>
        {
            new("@VersionId", versionId),
            new("@ResponsablesJson", JsonSerializer.Serialize(payload)),
            new("@Usuario", request.Usuario)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_GUARDAR_RESPONSABLES_ET, parametros);
        return await reader.ReadAsync() ? reader.MapTo<GuardarResponsablesEtResponse>() : new GuardarResponsablesEtResponse
        {
            CodigoResultado = -1,
            Mensaje = "El procedimiento no devolvió resultado."
        };
    }

    public async Task<CatalogosIngredientesEtDto> ObtenerCatalogosIngredientesAsync()
    {
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_OBTENER_CATALOGOS_INGREDIENTES_ET);
        var ingredientes = new List<IngredienteEtCatalogoDto>();
        while (await reader.ReadAsync()) ingredientes.Add(reader.MapTo<IngredienteEtCatalogoDto>());

        var tiposContenido = new List<TipoContenidoEtCatalogoDto>();
        if (await reader.NextResultAsync())
            while (await reader.ReadAsync()) tiposContenido.Add(reader.MapTo<TipoContenidoEtCatalogoDto>());

        return new CatalogosIngredientesEtDto { Ingredientes = ingredientes, TiposContenido = tiposContenido };
    }

    public async Task<GuardarIngredientesEtResponse> GuardarIngredientesAsync(int versionId, GuardarIngredientesEtRequest request)
    {
        var payload = new
        {
            ingredientes = request.Ingredientes.Select(x => new
            {
                ingredienteId = x.IngredienteId,
                unidadDeMedida = x.UnidadDeMedida,
                valor = x.Valor,
                idTipoContenido = x.IdTipoContenido,
                orden = x.Orden
            })
        };
        var parametros = new List<SqlParameter>
        {
            new("@VersionId", versionId),
            new("@IngredientesJson", JsonSerializer.Serialize(payload)),
            new("@Usuario", request.Usuario)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_GUARDAR_INGREDIENTES_ET, parametros);
        return await reader.ReadAsync() ? reader.MapTo<GuardarIngredientesEtResponse>() : new GuardarIngredientesEtResponse
        {
            CodigoResultado = -1,
            Mensaje = "El procedimiento no devolvió resultado."
        };
    }

    public async Task<GuardarRecetasEtResponse> GuardarRecetasAsync(int versionId, GuardarRecetasEtRequest request)
    {
        var payload = new
        {
            recetas = request.Recetas.Select(x => new
            {
                descripcion = x.Descripcion,
                idTipoContenido = x.IdTipoContenido,
                orden = x.Orden
            })
        };
        var parametros = new List<SqlParameter>
        {
            new("@VersionId", versionId),
            new("@RecetasJson", JsonSerializer.Serialize(payload)),
            new("@Usuario", request.Usuario)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_GUARDAR_RECETAS_ET, parametros);
        return await reader.ReadAsync() ? reader.MapTo<GuardarRecetasEtResponse>() : new GuardarRecetasEtResponse
        {
            CodigoResultado = -1,
            Mensaje = "El procedimiento no devolvió resultado."
        };
    }

    public async Task<GuardarProcedimientosEtResponse> GuardarProcedimientosAsync(int versionId, GuardarProcedimientosEtRequest request)
    {
        var payload = new
        {
            procedimientos = request.Procedimientos.Select(x => new
            {
                descripcion = x.Descripcion,
                idTipoContenido = x.IdTipoContenido,
                orden = x.Orden
            })
        };
        var parametros = new List<SqlParameter>
        {
            new("@VersionId", versionId),
            new("@ProcedimientosJson", JsonSerializer.Serialize(payload)),
            new("@Usuario", request.Usuario)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_GUARDAR_PROCEDIMIENTOS_ET, parametros);
        return await reader.ReadAsync() ? reader.MapTo<GuardarProcedimientosEtResponse>() : new GuardarProcedimientosEtResponse
        {
            CodigoResultado = -1,
            Mensaje = "El procedimiento no devolvió resultado."
        };
    }

    public async Task<CatalogosTratamientosEtDto> ObtenerCatalogosTratamientosAsync()
    {
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_OBTENER_CATALOGOS_TRATAMIENTOS_ET);
        var tratamientos = new List<TratamientoEtCatalogoDto>();
        while (await reader.ReadAsync()) tratamientos.Add(reader.MapTo<TratamientoEtCatalogoDto>());
        var parametros = new List<ParametroTratamientoEtCatalogoDto>();
        if (await reader.NextResultAsync())
            while (await reader.ReadAsync()) parametros.Add(reader.MapTo<ParametroTratamientoEtCatalogoDto>());
        var criterios = new List<TipoCriterioTratamientoEtCatalogoDto>();
        if (await reader.NextResultAsync())
            while (await reader.ReadAsync()) criterios.Add(reader.MapTo<TipoCriterioTratamientoEtCatalogoDto>());
        return new CatalogosTratamientosEtDto { Tratamientos = tratamientos, Parametros = parametros, TiposCriterio = criterios };
    }

    public async Task<GuardarTratamientosEtResponse> GuardarTratamientosAsync(int versionId, GuardarTratamientosEtRequest request)
    {
        var payload = new
        {
            tratamientos = request.Tratamientos.Select(t => new
            {
                tratConservId = t.TratConservId,
                parametros = t.Parametros.Select(p => new
                {
                    parametroTratId = p.ParametroTratId,
                    tipoCriterioId = p.TipoCriterioId,
                    valorCuantitativoInicial = p.ValorCuantitativoInicial,
                    valorCuantitativoFinal = p.ValorCuantitativoFinal,
                    valorCuantitativoIgual = p.ValorCuantitativoIgual,
                    valorCualitativo = p.ValorCualitativo,
                    orden = p.Orden
                })
            })
        };
        var parametros = new List<SqlParameter>
        {
            new("@VersionId", versionId),
            new("@TratamientosJson", JsonSerializer.Serialize(payload)),
            new("@Usuario", request.Usuario)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_GUARDAR_TRATAMIENTOS_ET, parametros);
        return await reader.ReadAsync() ? reader.MapTo<GuardarTratamientosEtResponse>() : new GuardarTratamientosEtResponse
        {
            CodigoResultado = -1,
            Mensaje = "El procedimiento no devolvió resultado."
        };
    }

    public async Task<GuardarInstruccionesEtResponse> GuardarInstruccionesAsync(int versionId, GuardarInstruccionesEtRequest request)
    {
        var payload = new
        {
            instrucciones = request.Instrucciones.Select(x => new
            {
                descripcion = x.Descripcion,
                orden = x.Orden
            })
        };
        var parametros = new List<SqlParameter>
        {
            new("@VersionId", versionId),
            new("@InstruccionesJson", JsonSerializer.Serialize(payload)),
            new("@Usuario", request.Usuario)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_GUARDAR_INSTRUCCIONES_ET, parametros);
        return await reader.ReadAsync() ? reader.MapTo<GuardarInstruccionesEtResponse>() : new GuardarInstruccionesEtResponse
        {
            CodigoResultado = -1,
            Mensaje = "El procedimiento no devolvió resultado."
        };
    }

    public async Task<IReadOnlyList<ContenidoRotuladoCatalogoDto>> ObtenerCatalogoContenidoRotuladoAsync()
    {
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_OBTENER_CATALOGO_CONTENIDO_ROTULADO_ET, []);
        var items = new List<ContenidoRotuladoCatalogoDto>();
        while (await reader.ReadAsync()) items.Add(reader.MapTo<ContenidoRotuladoCatalogoDto>());
        return items;
    }

    public async Task<GuardarContenidoRotuladoEtResponse> GuardarContenidoRotuladoAsync(int versionId, GuardarContenidoRotuladoEtRequest request)
    {
        var payload = new
        {
            contenidoRotulado = request.ContenidoRotulado.Select(x => new { contRotuladoId = x.ContRotuladoId, orden = x.Orden })
        };
        var parametros = new List<SqlParameter>
        {
            new("@VersionId", versionId),
            new("@ContenidoRotuladoJson", JsonSerializer.Serialize(payload)),
            new("@Usuario", request.Usuario)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_GUARDAR_CONTENIDO_ROTULADO_ET, parametros);
        return await reader.ReadAsync() ? reader.MapTo<GuardarContenidoRotuladoEtResponse>() : new GuardarContenidoRotuladoEtResponse
        {
            CodigoResultado = -1,
            Mensaje = "El procedimiento no devolvió resultado."
        };
    }

    public async Task<GuardarAnexosEtResponse> GuardarAnexosAsync(int versionId, GuardarAnexosEtRequest request)
    {
        var payload = new { anexos = request.Anexos.Select(x => new { descripcion = x.Descripcion }) };
        var parametros = new List<SqlParameter>
        {
            new("@VersionId", versionId),
            new("@AnexosJson", JsonSerializer.Serialize(payload)),
            new("@Usuario", request.Usuario)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_GUARDAR_ANEXOS_ET, parametros);
        return await reader.ReadAsync() ? reader.MapTo<GuardarAnexosEtResponse>() : new GuardarAnexosEtResponse
        {
            CodigoResultado = -1,
            Mensaje = "El procedimiento no devolvió resultado."
        };
    }

    public async Task<GuardarCambiosEtResponse> GuardarCambiosAsync(int versionId, GuardarCambiosEtRequest request)
    {
        var payload = new
        {
            cambios = request.Cambios.Select(x => new
            {
                numeroRevision = x.NumeroRevision,
                fechaActualizacion = x.FechaActualizacion.ToString("yyyy-MM-dd"),
                descripcion = x.Descripcion
            })
        };
        var parametros = new List<SqlParameter>
        {
            new("@VersionId", versionId),
            new("@CambiosJson", JsonSerializer.Serialize(payload)),
            new("@Usuario", request.Usuario)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_GUARDAR_CAMBIOS_ET, parametros);
        return await reader.ReadAsync() ? reader.MapTo<GuardarCambiosEtResponse>() : new GuardarCambiosEtResponse
        {
            CodigoResultado = -1,
            Mensaje = "El procedimiento no devolvió resultado."
        };
    }

    public async Task<GuardarCaracteristicaEtResponse> GuardarCaracteristicaAsync(int versionId, GuardarCaracteristicaEtRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@VersionId", versionId),
            new("@VersCaractId", (object?)request.VersCaractId ?? DBNull.Value),
            new("@CaracteristicaId", request.CaracteristicaId),
            new("@TipoCriterioId", request.TipoCriterioId),
            new("@ValorCuantitativoInicial", (object?)request.ValorCuantitativoInicial ?? DBNull.Value),
            new("@ValorCuantitativoFinal", (object?)request.ValorCuantitativoFinal ?? DBNull.Value),
            new("@ValorCuantitativoIgual", (object?)request.ValorCuantitativoIgual ?? DBNull.Value),
            new("@ValorCualitativo", (object?)request.ValorCualitativo ?? DBNull.Value),
            new("@FaseId", (object?)request.FaseId ?? DBNull.Value),
            new("@UnidadDeMedida", (object?)request.UnidadDeMedida ?? DBNull.Value),
            new("@EsObligatorio", request.EsObligatorio),
            new("@Orden", request.Orden),
            new("@Usuario", request.Usuario)
        };

        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_GUARDAR_CARACTERISTICA_ET, parametros);
        return await reader.ReadAsync() ? reader.MapTo<GuardarCaracteristicaEtResponse>() : new GuardarCaracteristicaEtResponse
        {
            CodigoResultado = -1,
            Mensaje = "El procedimiento no devolvió resultado."
        };
    }

    public async Task<EliminarCaracteristicaEtResponse> EliminarCaracteristicaAsync(int versionId, int versCaractId, EliminarCaracteristicaEtRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@VersionId", versionId),
            new("@VersCaractId", versCaractId),
            new("@Usuario", request.Usuario)
        };

        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_ELIMINAR_CARACTERISTICA_ET, parametros);
        return await reader.ReadAsync() ? reader.MapTo<EliminarCaracteristicaEtResponse>() : new EliminarCaracteristicaEtResponse
        {
            CodigoResultado = -1,
            Mensaje = "El procedimiento no devolvió resultado."
        };
    }

    public async Task<CambiarEstadoVersionEtResponse> CambiarEstadoAsync(int versionId, CambiarEstadoVersionEtRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@VersionId", versionId),
            new("@Accion", request.Accion),
            new("@Comentario", (object?)request.Comentario ?? DBNull.Value),
            new("@Usuario", request.Usuario)
        };

        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_CAMBIAR_ESTADO_VERSION_ET, parametros);
        var response = await reader.ReadAsync() ? reader.MapTo<CambiarEstadoVersionEtResponse>() : new CambiarEstadoVersionEtResponse
        {
            CodigoResultado = -1,
            Mensaje = "El procedimiento no devolvió resultado."
        };

        if (response.CodigoResultado == 0 &&
            string.Equals(request.Accion, "ENVIAR_REVISION", StringComparison.OrdinalIgnoreCase))
        {
            var parametrosNotificacion = new List<SqlParameter>
            {
                new("@VersionId", versionId),
                new("@Usuario", request.Usuario)
            };

            using var notificacionReader = await _executor.ExecuteReaderAsync(
                SPNames.SP_GENERAR_NOTIFICACIONES_REVISION_ET,
                parametrosNotificacion);

            if (await notificacionReader.ReadAsync())
            {
                var codigoNotificacion = notificacionReader.GetInt32(
                    notificacionReader.GetOrdinal("CodigoResultado"));

                if (codigoNotificacion != 0)
                    throw new InvalidOperationException("No se pudieron generar las notificaciones de revisión de la ET.");
            }
        }

        if (response.CodigoResultado == 0 &&
            string.Equals(request.Accion, "OBSERVAR", StringComparison.OrdinalIgnoreCase))
        {
            var parametrosNotificacion = new List<SqlParameter>
            {
                new("@VersionId", versionId),
                new("@Usuario", request.Usuario)
            };

            using var notificacionReader = await _executor.ExecuteReaderAsync(
                SPNames.SP_GENERAR_NOTIFICACION_ET_OBSERVADA,
                parametrosNotificacion);

            if (await notificacionReader.ReadAsync())
            {
                var codigoNotificacion = notificacionReader.GetInt32(
                    notificacionReader.GetOrdinal("CodigoResultado"));

                if (codigoNotificacion != 0)
                    throw new InvalidOperationException("No se pudo generar la notificación de ET observada.");
            }
        }

        if (response.CodigoResultado == 0 &&
            (string.Equals(request.Accion, "PUBLICAR", StringComparison.OrdinalIgnoreCase) ||
             string.Equals(request.Accion, "VIGENTAR", StringComparison.OrdinalIgnoreCase)))
        {
            var parametrosNotificacion = new List<SqlParameter>
            {
                new("@VersionId", versionId),
                new("@Accion", request.Accion),
                new("@Usuario", request.Usuario)
            };

            using var notificacionReader = await _executor.ExecuteReaderAsync(
                SPNames.SP_GENERAR_NOTIFICACION_GENERAL_ET,
                parametrosNotificacion);

            if (await notificacionReader.ReadAsync())
            {
                var codigoNotificacion = notificacionReader.GetInt32(
                    notificacionReader.GetOrdinal("CodigoResultado"));

                if (codigoNotificacion != 0)
                    throw new InvalidOperationException("No se pudieron generar las notificaciones generales de la ET.");
            }
        }

        return response;
    }


    public async Task<OperacionEstructuraEtResponse> ResetearAsync(int versionId, QuitarSeccionVersionEtRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@VersionId", versionId),
            new("@Usuario", request.Usuario)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_RESETEAR_ESPECIFICACION_TECNICA, parametros);
        return await reader.ReadAsync() ? reader.MapTo<OperacionEstructuraEtResponse>() : new OperacionEstructuraEtResponse { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado." };
    }

    public async Task<OperacionEstructuraEtResponse> EliminarBorradorAsync(int versionId, QuitarSeccionVersionEtRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@VersionId", versionId),
            new("@Usuario", request.Usuario)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_ELIMINAR_ESPECIFICACION_TECNICA_BORRADOR, parametros);
        return await reader.ReadAsync() ? reader.MapTo<OperacionEstructuraEtResponse>() : new OperacionEstructuraEtResponse { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado." };
    }


    public async Task<IReadOnlyList<EspecificacionTecnicaListadoDto>> ListarAsync(ListarEspecificacionesTecnicasFiltro filtro)
    {
        var parametros = new List<SqlParameter>
        {
            new("@Busqueda", (object?)filtro.Busqueda ?? DBNull.Value),
            new("@CodigoGenesis", (object?)filtro.ProductoCodigo ?? DBNull.Value),
            new("@EstVerId", (object?)filtro.EstVerId ?? DBNull.Value)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_LISTAR_ESPECIFICACIONES_TECNICAS, parametros);
        var items = new List<EspecificacionTecnicaListadoDto>();
        while (await reader.ReadAsync()) items.Add(reader.MapTo<EspecificacionTecnicaListadoDto>());
        return items;
    }
}

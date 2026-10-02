using Microsoft.Data.SqlClient;
using OVOCALIDAD.Application.DTOs.Mantenimientos;
using OVOCALIDAD.Infrastructure.Mappers;
using SPNames = OVOCALIDAD.Shared.Constants.StoredProcedures;

namespace OVOCALIDAD.Infrastructure.StoredProcedures;

public class MantenimientoStoredProcedure
{

    public async Task<IReadOnlyList<FaseMantenimientoDto>> ListarFasesAsync(string? buscar, bool incluirInactivos)
    {
        var parametros = new List<SqlParameter>
        {
            new("@Buscar", (object?)buscar ?? DBNull.Value),
            new("@IncluirInactivos", incluirInactivos)
        };
        using var reader = await _executor.ExecuteReaderAsync("dbo.SP_LISTAR_FASES", parametros);
        var items = new List<FaseMantenimientoDto>();
        while (await reader.ReadAsync()) items.Add(reader.MapTo<FaseMantenimientoDto>());
        return items;
    }

    public async Task<FaseMantenimientoDto> GuardarFaseAsync(GuardarFaseRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@FaseId", (object?)request.FaseId ?? DBNull.Value),
            new("@Codigo", request.Codigo),
            new("@Descripcion", request.Descripcion),
            new("@Usuario", request.Usuario)
        };
        using var reader = await _executor.ExecuteReaderAsync("dbo.SP_GUARDAR_FASE", parametros);
        if (await reader.ReadAsync()) return reader.MapTo<FaseMantenimientoDto>();
        throw new InvalidOperationException("El procedimiento no devolvió la fase.");
    }

    public async Task<FaseMantenimientoDto> CambiarEstadoFaseAsync(int faseId, CambiarEstadoFaseRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@FaseId", faseId),
            new("@Estado", request.Estado),
            new("@Usuario", request.Usuario)
        };
        using var reader = await _executor.ExecuteReaderAsync("dbo.SP_CAMBIAR_ESTADO_FASE", parametros);
        if (await reader.ReadAsync()) return reader.MapTo<FaseMantenimientoDto>();
        throw new InvalidOperationException("El procedimiento no devolvió la fase.");
    }

    private readonly StoredProcedureExecutor _executor;
    public MantenimientoStoredProcedure(StoredProcedureExecutor executor) => _executor = executor;

    public async Task<IReadOnlyList<IngredienteMantenimientoDto>> ListarIngredientesAsync(IngredienteMantenimientoFiltro filtro)
    {
        var parametros = new List<SqlParameter>
        {
            new("@Busqueda", (object?)filtro.Busqueda ?? DBNull.Value),
            new("@Estado", (object?)filtro.Estado ?? DBNull.Value)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_LISTAR_INGREDIENTES, parametros);
        var items = new List<IngredienteMantenimientoDto>();
        while (await reader.ReadAsync()) items.Add(reader.MapTo<IngredienteMantenimientoDto>());
        return items;
    }

    public async Task<GuardarIngredienteResponse> GuardarIngredienteAsync(GuardarIngredienteRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@IngredienteId", (object?)request.IngredienteId ?? DBNull.Value),
            new("@IngredienteDescripcion", request.IngredienteDescripcion),
            new("@UnidadDeMedida", DBNull.Value), // Compatibilidad con SP existente; el maestro ya no administra unidades.
            new("@Usuario", request.Usuario)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_GUARDAR_INGREDIENTE, parametros);
        return await reader.ReadAsync() ? reader.MapTo<GuardarIngredienteResponse>() : new GuardarIngredienteResponse { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado." };
    }

    public async Task<CambiarEstadoIngredienteResponse> CambiarEstadoIngredienteAsync(int ingredienteId, CambiarEstadoIngredienteRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@IngredienteId", ingredienteId),
            new("@Estado", request.Estado),
            new("@Usuario", request.Usuario)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_CAMBIAR_ESTADO_INGREDIENTE, parametros);
        return await reader.ReadAsync() ? reader.MapTo<CambiarEstadoIngredienteResponse>() : new CambiarEstadoIngredienteResponse { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado." };
    }

    public async Task<IReadOnlyList<CaracteristicaMantenimientoDto>> ListarCaracteristicasAsync(CaracteristicaMantenimientoFiltro filtro)
    {
        var parametros = new List<SqlParameter>
        {
            new("@Busqueda", (object?)filtro.Busqueda ?? DBNull.Value),
            new("@TipoCaractId", (object?)filtro.TipoCaractId ?? DBNull.Value),
            new("@Estado", (object?)filtro.Estado ?? DBNull.Value)
        };

        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_LISTAR_CARACTERISTICAS, parametros);
        var items = new List<CaracteristicaMantenimientoDto>();
        while (await reader.ReadAsync()) items.Add(reader.MapTo<CaracteristicaMantenimientoDto>());
        return items;
    }

    public async Task<CatalogosCaracteristicaMantenimientoDto> ObtenerCatalogosCaracteristicaAsync()
    {
        using var reader = await _executor.ExecuteReaderAsync(
            SPNames.SP_OBTENER_CATALOGOS_CARACTERISTICA,
            new List<SqlParameter>());

        var tipos = new List<TipoCaracteristicaMantenimientoDto>();
        while (await reader.ReadAsync()) tipos.Add(reader.MapTo<TipoCaracteristicaMantenimientoDto>());

        var metodos = new List<MetodoEnsayoMantenimientoDto>();
        if (await reader.NextResultAsync())
            while (await reader.ReadAsync()) metodos.Add(reader.MapTo<MetodoEnsayoMantenimientoDto>());

        return new CatalogosCaracteristicaMantenimientoDto
        {
            TiposCaracteristica = tipos,
            MetodosEnsayo = metodos
        };
    }

    public async Task<GuardarCaracteristicaResponse> GuardarCaracteristicaAsync(GuardarCaracteristicaRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@CaracteristicaId", (object?)request.CaracteristicaId ?? DBNull.Value),
            new("@CaracteristicaDescripcion", request.CaracteristicaDescripcion),
            new("@CaracteristicaUnidadDeMedida", (object?)request.CaracteristicaUnidadDeMedida ?? DBNull.Value),
            new("@TipoCaractId", request.TipoCaractId),
            new("@MetEnsayoId", (object?)request.MetEnsayoId ?? DBNull.Value),
            new("@Usuario", request.Usuario)
        };

        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_GUARDAR_CARACTERISTICA, parametros);
        return await reader.ReadAsync()
            ? reader.MapTo<GuardarCaracteristicaResponse>()
            : new GuardarCaracteristicaResponse { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado." };
    }

    public async Task<CambiarEstadoCaracteristicaResponse> CambiarEstadoCaracteristicaAsync(
        int caracteristicaId,
        CambiarEstadoCaracteristicaRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@CaracteristicaId", caracteristicaId),
            new("@Estado", request.Estado),
            new("@Usuario", request.Usuario)
        };

        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_CAMBIAR_ESTADO_CARACTERISTICA, parametros);
        return await reader.ReadAsync()
            ? reader.MapTo<CambiarEstadoCaracteristicaResponse>()
            : new CambiarEstadoCaracteristicaResponse { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado." };
    }

    public async Task<IReadOnlyList<TipoCaracteristicaMantenimientoDetalleDto>> ListarTiposCaracteristicaAsync(TipoCaracteristicaMantenimientoFiltro filtro)
    {
        var parametros = new List<SqlParameter>
        {
            new("@Busqueda", (object?)filtro.Busqueda ?? DBNull.Value),
            new("@Estado", (object?)filtro.Estado ?? DBNull.Value)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_LISTAR_TIPOS_CARACTERISTICA, parametros);
        var items = new List<TipoCaracteristicaMantenimientoDetalleDto>();
        while (await reader.ReadAsync()) items.Add(reader.MapTo<TipoCaracteristicaMantenimientoDetalleDto>());
        return items;
    }

    public async Task<GuardarTipoCaracteristicaResponse> GuardarTipoCaracteristicaAsync(GuardarTipoCaracteristicaRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@TipoCaractId", (object?)request.TipoCaractId ?? DBNull.Value),
            new("@TipoCaractDescripcion", request.TipoCaractDescripcion),
            new("@Usuario", request.Usuario)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_GUARDAR_TIPO_CARACTERISTICA, parametros);
        return await reader.ReadAsync() ? reader.MapTo<GuardarTipoCaracteristicaResponse>() : new GuardarTipoCaracteristicaResponse { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado." };
    }

    public async Task<CambiarEstadoTipoCaracteristicaResponse> CambiarEstadoTipoCaracteristicaAsync(int tipoCaractId, CambiarEstadoTipoCaracteristicaRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@TipoCaractId", tipoCaractId),
            new("@Estado", request.Estado),
            new("@Usuario", request.Usuario)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_CAMBIAR_ESTADO_TIPO_CARACTERISTICA, parametros);
        return await reader.ReadAsync() ? reader.MapTo<CambiarEstadoTipoCaracteristicaResponse>() : new CambiarEstadoTipoCaracteristicaResponse { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado." };
    }

    public async Task<IReadOnlyList<MetodoEnsayoMantenimientoDetalleDto>> ListarMetodosEnsayoAsync(MetodoEnsayoMantenimientoFiltro filtro)
    {
        var parametros = new List<SqlParameter>
        {
            new("@Busqueda", (object?)filtro.Busqueda ?? DBNull.Value),
            new("@Estado", (object?)filtro.Estado ?? DBNull.Value)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_LISTAR_METODOS_ENSAYO, parametros);
        var items = new List<MetodoEnsayoMantenimientoDetalleDto>();
        while (await reader.ReadAsync()) items.Add(reader.MapTo<MetodoEnsayoMantenimientoDetalleDto>());
        return items;
    }

    public async Task<GuardarMetodoEnsayoResponse> GuardarMetodoEnsayoAsync(GuardarMetodoEnsayoRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@MetEnsayoId", (object?)request.MetEnsayoId ?? DBNull.Value),
            new("@MetEnsayoDescripcion", request.MetEnsayoDescripcion),
            new("@Usuario", request.Usuario)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_GUARDAR_METODO_ENSAYO, parametros);
        return await reader.ReadAsync() ? reader.MapTo<GuardarMetodoEnsayoResponse>() : new GuardarMetodoEnsayoResponse { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado." };
    }

    public async Task<CambiarEstadoMetodoEnsayoResponse> CambiarEstadoMetodoEnsayoAsync(int metEnsayoId, CambiarEstadoMetodoEnsayoRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@MetEnsayoId", metEnsayoId),
            new("@Estado", request.Estado),
            new("@Usuario", request.Usuario)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_CAMBIAR_ESTADO_METODO_ENSAYO, parametros);
        return await reader.ReadAsync() ? reader.MapTo<CambiarEstadoMetodoEnsayoResponse>() : new CambiarEstadoMetodoEnsayoResponse { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado." };
    }

    public async Task<IReadOnlyList<ContenidoRotuladoMantenimientoDto>> ListarContenidosRotuladoAsync(ContenidoRotuladoMantenimientoFiltro filtro)
    {
        var parametros = new List<SqlParameter>
        {
            new("@Busqueda", (object?)filtro.Busqueda ?? DBNull.Value),
            new("@Estado", (object?)filtro.Estado ?? DBNull.Value)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_LISTAR_CONTENIDOS_ROTULADO, parametros);
        var items = new List<ContenidoRotuladoMantenimientoDto>();
        while (await reader.ReadAsync()) items.Add(reader.MapTo<ContenidoRotuladoMantenimientoDto>());
        return items;
    }

    public async Task<GuardarContenidoRotuladoResponse> GuardarContenidoRotuladoAsync(GuardarContenidoRotuladoRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@ContRotuladoId", (object?)request.ContRotuladoId ?? DBNull.Value),
            new("@ContRotuladoDescripcion", request.ContRotuladoDescripcion),
            new("@Usuario", request.Usuario)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_GUARDAR_CONTENIDO_ROTULADO, parametros);
        return await reader.ReadAsync()
            ? reader.MapTo<GuardarContenidoRotuladoResponse>()
            : new GuardarContenidoRotuladoResponse { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado." };
    }

    public async Task<CambiarEstadoContenidoRotuladoResponse> CambiarEstadoContenidoRotuladoAsync(int contRotuladoId, CambiarEstadoContenidoRotuladoRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@ContRotuladoId", contRotuladoId),
            new("@Estado", request.Estado),
            new("@Usuario", request.Usuario)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_CAMBIAR_ESTADO_CONTENIDO_ROTULADO, parametros);
        return await reader.ReadAsync()
            ? reader.MapTo<CambiarEstadoContenidoRotuladoResponse>()
            : new CambiarEstadoContenidoRotuladoResponse { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado." };
    }

    public async Task<IReadOnlyList<CargoMantenimientoDto>> ListarCargosAsync(CargoMantenimientoFiltro filtro)
    {
        var parametros = new List<SqlParameter>
        {
            new("@Busqueda", (object?)filtro.Busqueda ?? DBNull.Value),
            new("@Estado", (object?)filtro.Estado ?? DBNull.Value)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_LISTAR_CARGOS, parametros);
        var items = new List<CargoMantenimientoDto>();
        while (await reader.ReadAsync()) items.Add(reader.MapTo<CargoMantenimientoDto>());
        return items;
    }

    public async Task<GuardarCargoResponse> GuardarCargoAsync(GuardarCargoRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@CargoId", (object?)request.CargoId ?? DBNull.Value),
            new("@CargoDescripcion", request.CargoDescripcion),
            new("@Usuario", request.Usuario)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_GUARDAR_CARGO, parametros);
        return await reader.ReadAsync() ? reader.MapTo<GuardarCargoResponse>() : new GuardarCargoResponse { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado." };
    }

    public async Task<CambiarEstadoCargoResponse> CambiarEstadoCargoAsync(int cargoId, CambiarEstadoCargoRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@CargoId", cargoId),
            new("@Estado", request.Estado),
            new("@Usuario", request.Usuario)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_CAMBIAR_ESTADO_CARGO, parametros);
        return await reader.ReadAsync() ? reader.MapTo<CambiarEstadoCargoResponse>() : new CambiarEstadoCargoResponse { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado." };
    }

    public async Task<IReadOnlyList<CargoActivoDto>> ObtenerCargosActivosAsync()
    {
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_OBTENER_CARGOS_ACTIVOS, new List<SqlParameter>());
        var items = new List<CargoActivoDto>();
        while (await reader.ReadAsync()) items.Add(reader.MapTo<CargoActivoDto>());
        return items;
    }

    public async Task<IReadOnlyList<ResponsableMantenimientoDto>> ListarResponsablesAsync(ResponsableMantenimientoFiltro filtro)
    {
        var parametros = new List<SqlParameter>
        {
            new("@Busqueda", (object?)filtro.Busqueda ?? DBNull.Value),
            new("@Estado", (object?)filtro.Estado ?? DBNull.Value)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_LISTAR_RESPONSABLES, parametros);
        var items = new List<ResponsableMantenimientoDto>();
        while (await reader.ReadAsync()) items.Add(reader.MapTo<ResponsableMantenimientoDto>());
        return items;
    }

    public async Task<CrearResponsableResponse> CrearResponsableAsync(CrearResponsableRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@UsuarioDni", request.UsuarioDni),
            new("@UsuarioNombresApellidos", request.UsuarioNombresApellidos),
            new("@CargoId", request.CargoId),
            new("@FechaInicioCargo", (object?)request.FechaInicioCargo?.Date ?? DBNull.Value),
            new("@Usuario", request.Usuario)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_CREAR_RESPONSABLE, parametros);
        return await reader.ReadAsync() ? reader.MapTo<CrearResponsableResponse>() : new CrearResponsableResponse { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado." };
    }

    public async Task<OperacionResponsableResponse> EditarResponsableAsync(string usuarioDni, EditarResponsableRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@UsuarioDni", usuarioDni),
            new("@UsuarioNombresApellidos", request.UsuarioNombresApellidos),
            new("@Usuario", request.Usuario)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_EDITAR_RESPONSABLE, parametros);
        return await reader.ReadAsync() ? reader.MapTo<OperacionResponsableResponse>() : new OperacionResponsableResponse { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado." };
    }

    public async Task<CambiarCargoResponsableResponse> CambiarCargoResponsableAsync(string usuarioDni, CambiarCargoResponsableRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@UsuarioDni", usuarioDni),
            new("@CargoId", request.CargoId),
            new("@FechaInicioCargo", (object?)request.FechaInicioCargo?.Date ?? DBNull.Value),
            new("@Usuario", request.Usuario)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_CAMBIAR_CARGO_RESPONSABLE, parametros);
        return await reader.ReadAsync() ? reader.MapTo<CambiarCargoResponsableResponse>() : new CambiarCargoResponsableResponse { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado." };
    }

    public async Task<IReadOnlyList<HistorialCargoResponsableDto>> ObtenerHistorialCargosResponsableAsync(string usuarioDni)
    {
        var parametros = new List<SqlParameter> { new("@UsuarioDni", usuarioDni) };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_OBTENER_HISTORIAL_CARGOS_RESPONSABLE, parametros);
        var items = new List<HistorialCargoResponsableDto>();
        while (await reader.ReadAsync()) items.Add(reader.MapTo<HistorialCargoResponsableDto>());
        return items;
    }

    public async Task<CambiarEstadoResponsableResponse> CambiarEstadoResponsableAsync(string usuarioDni, CambiarEstadoResponsableRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@UsuarioDni", usuarioDni),
            new("@Estado", request.Estado),
            new("@Usuario", request.Usuario)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_CAMBIAR_ESTADO_RESPONSABLE, parametros);
        return await reader.ReadAsync() ? reader.MapTo<CambiarEstadoResponsableResponse>() : new CambiarEstadoResponsableResponse { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado." };
    }

    public async Task<GuardarCargoHistoricoResponsableResponse> AgregarCargoHistoricoResponsableAsync(string usuarioDni, GuardarCargoHistoricoResponsableRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@UsuarioDni", usuarioDni),
            new("@CargoId", request.CargoId),
            new("@FechaInicio", (object?)request.FechaInicio?.Date ?? DBNull.Value),
            new("@FechaFin", (object?)request.FechaFin?.Date ?? DBNull.Value),
            new("@Usuario", request.Usuario)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_AGREGAR_CARGO_HISTORICO_RESPONSABLE, parametros);
        return await reader.ReadAsync() ? reader.MapTo<GuardarCargoHistoricoResponsableResponse>() : new GuardarCargoHistoricoResponsableResponse { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado." };
    }

    public async Task<GuardarCargoHistoricoResponsableResponse> EditarCargoHistoricoResponsableAsync(int usuarioCargoHistorialId, GuardarCargoHistoricoResponsableRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@UsuarioCargoHistorialId", usuarioCargoHistorialId),
            new("@CargoId", request.CargoId),
            new("@FechaInicio", (object?)request.FechaInicio?.Date ?? DBNull.Value),
            new("@FechaFin", (object?)request.FechaFin?.Date ?? DBNull.Value),
            new("@Usuario", request.Usuario)
        };
        using var reader = await _executor.ExecuteReaderAsync(SPNames.SP_EDITAR_HISTORIAL_CARGO_RESPONSABLE, parametros);
        return await reader.ReadAsync() ? reader.MapTo<GuardarCargoHistoricoResponsableResponse>() : new GuardarCargoHistoricoResponsableResponse { CodigoResultado = -1, Mensaje = "El procedimiento no devolvió resultado." };
    }
}

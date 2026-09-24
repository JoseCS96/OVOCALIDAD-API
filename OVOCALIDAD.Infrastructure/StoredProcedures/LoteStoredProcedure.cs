using Microsoft.Data.SqlClient;
using OVOCALIDAD.Application.DTOs.Lotes;
using OVOCALIDAD.Infrastructure.Mappers;
using SPNames = OVOCALIDAD.Shared.Constants.StoredProcedures;
using OVOCALIDAD.Shared.DTOs.GenerarLote;

namespace OVOCALIDAD.Infrastructure.StoredProcedures;

public class LoteStoredProcedure
{
    private readonly StoredProcedureExecutor _executor;

    public LoteStoredProcedure(StoredProcedureExecutor executor)
    {
        _executor = executor;
    }

    public async Task<GenerarLoteResponse> GenerarLoteAsync(
        GenerarLoteRequest request)
    {
        var parametros = new List<SqlParameter>
        {
            new("@ProductoCodigo", request.ProductoCodigo),
            new("@NaturalezaId", request.NaturalezaId),
            new("@FaseId", request.FaseId),
            new("@LineaOrigenId", request.LineaOrigenId),
            new("@Observacion", (object?)request.Observacion ?? DBNull.Value),
            new("@Usuario", request.Usuario)
        };

        using var reader = await _executor.ExecuteReaderAsync(
            SPNames.SP_GENERAR_LOTE,
            parametros);

        var response = new GenerarLoteResponse();

        if (await reader.ReadAsync())
        {
            response.Resultado = reader.MapTo<ResultadoOperacionDto>();
        }

        if (await reader.NextResultAsync())
        {
            if (await reader.ReadAsync())
            {
                response.Lote = reader.MapTo<LoteDto>();
            }
        }

        return response;
    }

    public async Task<IReadOnlyList<LoteListadoDto>> ListarLotesAsync(
        ListarLotesFiltro filtro)
    {
        var parametros = new List<SqlParameter>
        {
            new("@CodigoLote", (object?)filtro.CodigoLote ?? DBNull.Value),
            new("@ProductoCodigo", (object?)filtro.ProductoCodigo ?? DBNull.Value),
            new("@EstadoLoteId", (object?)filtro.EstadoLoteId ?? DBNull.Value),
            new("@EstadoEvaluacionId", (object?)filtro.EstadoEvaluacionId ?? DBNull.Value),
            new("@FechaDesde", (object?)filtro.FechaDesde?.Date ?? DBNull.Value),
            new("@FechaHasta", (object?)filtro.FechaHasta?.Date ?? DBNull.Value)
        };

        using var reader = await _executor.ExecuteReaderAsync(
            SPNames.SP_LISTAR_LOTES,
            parametros);

        var lotes = new List<LoteListadoDto>();

        while (await reader.ReadAsync())
        {
            lotes.Add(reader.MapTo<LoteListadoDto>());
        }

        return lotes;
    }

    public async Task<CatalogosLoteDto> ObtenerCatalogosAsync()
    {
        using var reader = await _executor.ExecuteReaderAsync(
            SPNames.SP_OBTENER_CATALOGOS_LOTE);

        var productos = new List<ProductoCatalogoDto>();
        while (await reader.ReadAsync())
            productos.Add(reader.MapTo<ProductoCatalogoDto>());

        var naturalezas = new List<CatalogoLoteDto>();
        if (await reader.NextResultAsync())
            while (await reader.ReadAsync())
                naturalezas.Add(reader.MapTo<CatalogoLoteDto>());

        var fases = new List<CatalogoLoteDto>();
        if (await reader.NextResultAsync())
            while (await reader.ReadAsync())
                fases.Add(reader.MapTo<CatalogoLoteDto>());

        var lineasOrigen = new List<CatalogoLoteDto>();
        if (await reader.NextResultAsync())
            while (await reader.ReadAsync())
                lineasOrigen.Add(reader.MapTo<CatalogoLoteDto>());

        return new CatalogosLoteDto
        {
            Productos = productos,
            Naturalezas = naturalezas,
            Fases = fases,
            LineasOrigen = lineasOrigen
        };
    }

}

using Microsoft.Data.SqlClient;
using OVOCALIDAD.Application.DTOs.Lotes;
using OVOCALIDAD.Infrastructure.Mappers;
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
            "SP_GENERAR_LOTE",
            parametros);

        var response = new GenerarLoteResponse();

        // ===========================
        // ResultSet 1
        // ===========================

        if (await reader.ReadAsync())
        {
            response.Resultado = reader.MapTo<ResultadoOperacionDto>();
        }

        // ===========================
        // ResultSet 2
        // ===========================

        if (await reader.NextResultAsync())
        {
            if (await reader.ReadAsync())
            {
                response.Lote = reader.MapTo<LoteDto>();
            }
        }

        return response;
    }
}
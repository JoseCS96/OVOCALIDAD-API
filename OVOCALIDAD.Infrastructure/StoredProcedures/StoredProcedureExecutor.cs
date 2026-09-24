using Microsoft.Data.SqlClient;
using OVOCALIDAD.Infrastructure.Data;
using System.Data;

namespace OVOCALIDAD.Infrastructure.StoredProcedures;

public class StoredProcedureExecutor
{
    private readonly SqlConnectionFactory _connectionFactory;

    public StoredProcedureExecutor(SqlConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    /// <summary>
    /// Ejecuta un Stored Procedure y devuelve un SqlDataReader.
    /// Ideal para CRUD y múltiples ResultSets.
    /// </summary>
    public async Task<SqlDataReader> ExecuteReaderAsync(
        string storedProcedure,
        List<SqlParameter>? parameters = null)
    {
        var connection = (SqlConnection)_connectionFactory.CreateConnection();

        var command = new SqlCommand(storedProcedure, connection)
        {
            CommandType = CommandType.StoredProcedure
        };

        if (parameters != null)
        {
            command.Parameters.AddRange(parameters.ToArray());
        }

        await connection.OpenAsync();

        return await command.ExecuteReaderAsync(CommandBehavior.CloseConnection);
    }

    /// <summary>
    /// Ejecuta un Stored Procedure y devuelve un DataSet.
    /// Útil para reportes o consultas tabulares.
    /// </summary>
    public async Task<DataSet> ExecuteDataSetAsync(
        string storedProcedure,
        List<SqlParameter>? parameters = null)
    {
        using var connection = (SqlConnection)_connectionFactory.CreateConnection();

        using var command = new SqlCommand(storedProcedure, connection)
        {
            CommandType = CommandType.StoredProcedure
        };

        if (parameters != null)
        {
            command.Parameters.AddRange(parameters.ToArray());
        }

        await connection.OpenAsync();

        using var adapter = new SqlDataAdapter(command);

        var ds = new DataSet();

        adapter.Fill(ds);

        return ds;
    }
}
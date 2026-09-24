using System.Data;
using System.Reflection;

namespace OVOCALIDAD.Infrastructure.Mappers;

public static class DataReaderMapper
{
    public static T MapTo<T>(this IDataRecord reader)
        where T : new()
    {
        T obj = new();

        var propiedades = typeof(T).GetProperties(BindingFlags.Public | BindingFlags.Instance);

        foreach (var propiedad in propiedades)
        {
            try
            {
                int ordinal = reader.GetOrdinal(propiedad.Name);

                if (reader.IsDBNull(ordinal))
                    continue;

                var valor = reader.GetValue(ordinal);

                var tipo = Nullable.GetUnderlyingType(propiedad.PropertyType)
                           ?? propiedad.PropertyType;

                propiedad.SetValue(
                    obj,
                    Convert.ChangeType(valor, tipo));
            }
            catch (IndexOutOfRangeException)
            {
                // La columna no existe en el ResultSet.
                // Se ignora.
            }
        }

        return obj;
    }
}
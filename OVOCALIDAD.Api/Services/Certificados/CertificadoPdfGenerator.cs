using System.Text.Json;
using OVOCALIDAD.Application.DTOs.Certificados;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;

namespace OVOCALIDAD.Api.Services.Certificados;

public static class CertificadoPdfGenerator
{
    public static byte[] Generate(CertificadoVistaDto data)
    {
        QuestPDF.Settings.License = LicenseType.Community;

        return Document.Create(document =>
        {
            document.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.Margin(20);
                page.DefaultTextStyle(x => x.FontSize(9));

                page.Content().Column(column =>
                {
                    column.Spacing(0);

                    foreach (var section in data.Secciones.OrderBy(x => x.OrdenSeccion))
                    {
                        if (section.TipoSeccion == "ENCABEZADO")
                        {
                            column.Item().Element(c => ComposeHeader(c, data, section));
                            continue;
                        }

                        if (section.TipoSeccion == "RESULTADOS")
                        {
                            column.Item().Element(c => ComposeResults(c, data, section));
                            continue;
                        }

                        column.Item().Element(c => ComposeSection(c, data, section));
                    }
                });

                page.Footer()
                    .AlignCenter()
                    .Text(text =>
                    {
                        text.Span("OVOCALIDAD 2.0 · ");
                        text.CurrentPageNumber();
                        text.Span(" / ");
                        text.TotalPages();
                    })
                    .FontSize(8)
                    .FontColor(Colors.Grey.Darken1);
            });
        }).GeneratePdf();
    }

    private static void ComposeHeader(IContainer container, CertificadoVistaDto data, CertificadoSeccionVistaDto section)
    {
        var values = Parse(section.Contenido);
        var title = Get(values, "titulo") ?? "ASEGURAMIENTO DE LA CALIDAD";
        var subtitle = Get(values, "subtitulo") ?? "CERTIFICADO DE ANÁLISIS";

        container
            .Border(1)
            .BorderColor(Colors.Grey.Lighten1)
            .Row(row =>
            {
                row.RelativeItem(1)
                    .Padding(10)
                    .AlignMiddle()
                    .Text("Ovosur")
                    .Bold()
                    .Italic()
                    .FontSize(18);

                row.RelativeItem(2)
                    .BorderLeft(1)
                    .BorderRight(1)
                    .BorderColor(Colors.Grey.Lighten1)
                    .Padding(10)
                    .Column(col =>
                    {
                        col.Item().AlignCenter().Text(title).Bold().FontSize(9);
                        col.Item().AlignCenter().Text(subtitle).Bold().FontSize(13);
                    });

                row.RelativeItem(1)
                    .Padding(7)
                    .Column(col =>
                    {
                        col.Spacing(3);
                        col.Item().Text($"N°: {data.Cabecera.NumeroCertificado ?? "Previsualización"}").Bold();
                        col.Item().Text($"FT: {data.Cabecera.DocumentoCodigo}");
                        col.Item().Text($"Fecha: {data.Cabecera.FechaEmision:dd/MM/yyyy}");
                    });
            });
    }

    private static void ComposeSection(IContainer container, CertificadoVistaDto data, CertificadoSeccionVistaDto section)
    {
        container
            .BorderLeft(1)
            .BorderRight(1)
            .BorderBottom(1)
            .BorderColor(Colors.Grey.Lighten1)
            .Padding(10)
            .Column(col =>
            {
                col.Spacing(6);
                col.Item().Text(section.TituloSeccion ?? section.TipoSeccion).Bold().FontSize(10);

                switch (section.TipoSeccion)
                {
                    case "DATOS_EMPRESA":
                        ComposeObject(col, section.Contenido, new[]
                        {
                            ("razonSocial","Razón Social"),
                            ("nombreComercial","Nombre Comercial"),
                            ("direccion","Dirección"),
                            ("telefono","Teléfono"),
                            ("fax","Fax"),
                            ("correo","Correo"),
                            ("sitioWeb","Sitio Web"),
                            ("ruc","RUC")
                        });
                        break;

                    case "PRODUCTO":
                        ComposeObject(col, section.Contenido, new[]
                        {
                            ("productoCodigo","Producto Código"),
                            ("productoDescripcion","Producto Descripción"),
                            ("fichaTecnica","Ficha Técnica"),
                            ("versionFt","Versión FT")
                        });
                        break;

                    case "DATOS_LOTE":
                        ComposeLotData(col, section.Contenido);
                        break;

                    case "FIRMA":
                        ComposeSignature(col, section.Contenido);
                        break;

                    default:
                        col.Item().Text(section.Contenido ?? "—");
                        break;
                }
            });
    }

    private static void ComposeResults(IContainer container, CertificadoVistaDto data, CertificadoSeccionVistaDto section)
    {
        var groups = data.Resultados
            .GroupBy(x => new { x.OrdenInforme, x.TituloInforme })
            .OrderBy(x => x.Key.OrdenInforme)
            .ToList();

        container
            .BorderLeft(1)
            .BorderRight(1)
            .BorderBottom(1)
            .BorderColor(Colors.Grey.Lighten1)
            .Padding(10)
            .Column(col =>
            {
                col.Spacing(8);
                col.Item().Text(section.TituloSeccion ?? "Resultados y evaluaciones").Bold().FontSize(10);

                foreach (var group in groups)
                {
                    col.Item().Text(group.Key.TituloInforme).Bold().FontSize(10);

                    col.Item().Table(table =>
                    {
                        table.ColumnsDefinition(columns =>
                        {
                            columns.RelativeColumn(3);
                            columns.RelativeColumn(1.3f);
                            columns.RelativeColumn(1.6f);
                            columns.RelativeColumn(1f);
                            columns.RelativeColumn(1.8f);
                        });

                        HeaderCell(table, "Determinación");
                        HeaderCell(table, "Resultado");
                        HeaderCell(table, "Especificación");
                        HeaderCell(table, "Unidad");
                        HeaderCell(table, "Método");

                        foreach (var result in group.OrderBy(x => x.OrdenDetalle))
                        {
                            Cell(table, result.Determinacion);
                            Cell(table, result.Resultado ?? "—");
                            Cell(table, result.Especificacion ?? "—");
                            Cell(table, result.UnidadDeMedida ?? "—");
                            Cell(table, result.MetodoEnsayo ?? "—");
                        }
                    });
                }
            });
    }

    private static void ComposeObject(
        ColumnDescriptor col,
        string? json,
        IEnumerable<(string Key, string Label)> fields)
    {
        var values = Parse(json);

        col.Item().Table(table =>
        {
            table.ColumnsDefinition(columns =>
            {
                columns.RelativeColumn();
                columns.RelativeColumn();
            });

            var index = 0;
            foreach (var field in fields)
            {
                var value = Get(values, field.Key);
                if (string.IsNullOrWhiteSpace(value))
                    continue;

                table.Cell()
                    .Column(index % 2 + 1)
                    .PaddingVertical(2)
                    .Text(text =>
                    {
                        text.Span(field.Label + ": ").Bold();
                        text.Span(value);
                    });

                index++;
            }
        });
    }

    private static void ComposeLotData(ColumnDescriptor col, string? json)
    {
        var values = Parse(json);

        var production = FormatDate(Get(values, "fechaProduccion"));
        var expiration = FormatDate(Get(values, "fechaCaducidad"));
        var lot = Get(values, "lote") ?? "—";
        var shelfLife = Get(values, "vidaUtil") ?? "—";

        col.Item().Table(table =>
        {
            table.ColumnsDefinition(columns =>
            {
                columns.RelativeColumn();
                columns.RelativeColumn();
            });

            PairCell(table, "Fecha Producción", production);
            PairCell(table, "Fecha Caducidad", expiration);
            PairCell(table, "N° Lote", lot);
            PairCell(table, "Vida Útil", shelfLife);
        });
    }

    private static void ComposeSignature(ColumnDescriptor col, string? json)
    {
        var values = Parse(json);
        var responsible = Get(values, "responsable") ?? "[Responsable]";
        var role = Get(values, "cargo") ?? "[Cargo]";
        var date = FormatDate(Get(values, "fecha"));

        col.Item()
            .PaddingTop(22)
            .AlignRight()
            .Width(220)
            .BorderTop(1)
            .BorderColor(Colors.Grey.Darken1)
            .PaddingTop(4)
            .Column(signature =>
            {
                signature.Item().AlignCenter().Text(responsible).Bold();
                signature.Item().AlignCenter().Text(role).FontColor(Colors.Grey.Darken1);
                signature.Item().AlignCenter().Text(date).FontSize(8).FontColor(Colors.Grey.Darken1);
            });
    }

    private static void PairCell(TableDescriptor table, string label, string value)
    {
        table.Cell()
            .PaddingVertical(3)
            .PaddingRight(10)
            .Text(text =>
            {
                text.Span(label + ": ").Bold();
                text.Span(value);
            });
    }

    private static void HeaderCell(TableDescriptor table, string value)
    {
        table.Cell()
            .Background(Colors.Grey.Lighten4)
            .Border(0.5f)
            .BorderColor(Colors.Grey.Lighten2)
            .Padding(5)
            .Text(value)
            .Bold()
            .FontSize(8);
    }

    private static void Cell(TableDescriptor table, string value)
    {
        table.Cell()
            .Border(0.5f)
            .BorderColor(Colors.Grey.Lighten2)
            .Padding(5)
            .Text(value)
            .FontSize(8);
    }

    private static Dictionary<string, JsonElement> Parse(string? json)
    {
        if (string.IsNullOrWhiteSpace(json))
            return new Dictionary<string, JsonElement>(StringComparer.OrdinalIgnoreCase);

        try
        {
            using var document = JsonDocument.Parse(json);
            if (document.RootElement.ValueKind != JsonValueKind.Object)
                return new Dictionary<string, JsonElement>(StringComparer.OrdinalIgnoreCase);

            return document.RootElement
                .EnumerateObject()
                .ToDictionary(
                    x => x.Name,
                    x => x.Value.Clone(),
                    StringComparer.OrdinalIgnoreCase);
        }
        catch
        {
            return new Dictionary<string, JsonElement>(StringComparer.OrdinalIgnoreCase);
        }
    }

    private static string? Get(Dictionary<string, JsonElement> values, string key)
    {
        if (!values.TryGetValue(key, out var value))
            return null;

        return value.ValueKind switch
        {
            JsonValueKind.String => value.GetString(),
            JsonValueKind.Number => value.ToString(),
            JsonValueKind.True => "Sí",
            JsonValueKind.False => "No",
            JsonValueKind.Null => null,
            _ => value.ToString()
        };
    }

    private static string FormatDate(string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
            return "—";

        return DateTime.TryParse(value, out var date)
            ? date.ToString("dd/MM/yyyy HH:mm")
            : value;
    }
}

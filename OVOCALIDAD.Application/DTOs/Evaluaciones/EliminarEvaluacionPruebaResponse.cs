namespace OVOCALIDAD.Application.DTOs.Evaluaciones;

public class EliminarEvaluacionPruebaResponse
{
    public int CodigoResultado { get; set; }
    public string Mensaje { get; set; } = string.Empty;
    public int EvaluacionId { get; set; }
    public string Usuario { get; set; } = string.Empty;
}

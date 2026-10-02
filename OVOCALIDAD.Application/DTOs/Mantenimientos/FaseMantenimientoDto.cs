namespace OVOCALIDAD.Application.DTOs.Mantenimientos;

public class FaseMantenimientoDto
{
    public int FaseId { get; set; }
    public string Codigo { get; set; } = string.Empty;
    public string Descripcion { get; set; } = string.Empty;
    public string Estado { get; set; } = string.Empty;
    public DateTime? FechaCreacion { get; set; }
    public int? UsuarioCreacion { get; set; }
    public DateTime? FechaModificacion { get; set; }
    public int? UsuarioModificacion { get; set; }
}

public class GuardarFaseRequest
{
    public int? FaseId { get; set; }
    public string Codigo { get; set; } = string.Empty;
    public string Descripcion { get; set; } = string.Empty;
    public int? Usuario { get; set; }
}

public class CambiarEstadoFaseRequest
{
    public string Estado { get; set; } = string.Empty;
    public int? Usuario { get; set; }
}

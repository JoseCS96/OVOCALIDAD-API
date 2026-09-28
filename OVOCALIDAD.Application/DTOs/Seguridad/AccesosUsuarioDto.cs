namespace OVOCALIDAD.Application.DTOs.Seguridad;

public class AccesosUsuarioDto
{
    public UsuarioAccesoDto Usuario { get; set; } = new();
    public IReadOnlyList<PerfilAccesoDto> Perfiles { get; set; } = Array.Empty<PerfilAccesoDto>();
    public IReadOnlyList<ModuloAccesoDto> Modulos { get; set; } = Array.Empty<ModuloAccesoDto>();
    public IReadOnlyList<string> Permisos { get; set; } = Array.Empty<string>();
}

public class UsuarioAccesoDto
{
    public int SegUsuarioId { get; set; }
    public string NombreUsuario { get; set; } = string.Empty;
    public string NombresApellidos { get; set; } = string.Empty;
    public string? Correo { get; set; }
    public DateTime? UltimoAcceso { get; set; }
}

public class PerfilAccesoDto
{
    public int PerfilId { get; set; }
    public string PerfilCodigo { get; set; } = string.Empty;
    public string PerfilDescripcion { get; set; } = string.Empty;
    public int? AreaId { get; set; }
    public string? AreaCodigo { get; set; }
    public string? AreaDescripcion { get; set; }
}

public class ModuloAccesoDto
{
    public int ModuloId { get; set; }
    public string ModuloCodigo { get; set; } = string.Empty;
    public string ModuloDescripcion { get; set; } = string.Empty;
    public string? Ruta { get; set; }
    public string? Icono { get; set; }
    public int Orden { get; set; }
}

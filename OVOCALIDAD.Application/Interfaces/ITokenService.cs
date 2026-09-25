using OVOCALIDAD.Application.DTOs.Seguridad;

namespace OVOCALIDAD.Application.Interfaces;

public interface ITokenService
{
    (string Token, DateTime ExpiraEn) CrearToken(UsuarioAutenticacionDto usuario);
}

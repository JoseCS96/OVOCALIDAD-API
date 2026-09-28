using OVOCALIDAD.Application.DTOs.Seguridad;
using OVOCALIDAD.Application.Interfaces;

namespace OVOCALIDAD.Application.Services;

public class AuthService : IAuthService
{
    private readonly IAuthRepository _repository;
    private readonly IPasswordService _passwordService;
    private readonly ITokenService _tokenService;

    public AuthService(
        IAuthRepository repository,
        IPasswordService passwordService,
        ITokenService tokenService)
    {
        _repository = repository;
        _passwordService = passwordService;
        _tokenService = tokenService;
    }

    public async Task<LoginResponse?> LoginAsync(LoginRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.NombreUsuario) ||
            string.IsNullOrWhiteSpace(request.Password))
            return null;

        var usuario = await _repository.ObtenerUsuarioAutenticacionAsync(request.NombreUsuario.Trim());

        if (usuario is null ||
            string.IsNullOrWhiteSpace(usuario.PasswordHash) ||
            !_passwordService.Verify(request.Password, usuario.PasswordHash))
            return null;

        var (token, expiraEn) = _tokenService.CrearToken(usuario);
        await _repository.ActualizarUltimoAccesoAsync(usuario.SegUsuarioId);

        return new LoginResponse
        {
            Token = token,
            ExpiraEn = expiraEn,
            Usuario = new UsuarioAccesoDto
            {
                SegUsuarioId = usuario.SegUsuarioId,
                NombreUsuario = usuario.NombreUsuario,
                NombresApellidos = usuario.NombresApellidos,
                Correo = usuario.Correo,
                UltimoAcceso = DateTime.Now
            }
        };
    }
}

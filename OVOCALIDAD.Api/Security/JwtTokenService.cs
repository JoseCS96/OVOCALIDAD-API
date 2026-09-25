using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using OVOCALIDAD.Application.DTOs.Seguridad;
using OVOCALIDAD.Application.Interfaces;

namespace OVOCALIDAD.Api.Security;

public class JwtTokenService : ITokenService
{
    private readonly IConfiguration _configuration;

    public JwtTokenService(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    public (string Token, DateTime ExpiraEn) CrearToken(UsuarioAutenticacionDto usuario)
    {
        var key = _configuration["Jwt:Key"]
            ?? throw new InvalidOperationException("Jwt:Key no está configurado.");

        var issuer = _configuration["Jwt:Issuer"] ?? "OVOCALIDAD.Api";
        var audience = _configuration["Jwt:Audience"] ?? "OVOCALIDAD.Web";
        var minutes = int.TryParse(_configuration["Jwt:ExpirationMinutes"], out var value) ? value : 480;
        var expiraEn = DateTime.UtcNow.AddMinutes(minutes);

        var claims = new[]
        {
            new Claim(JwtRegisteredClaimNames.Sub, usuario.SegUsuarioId.ToString()),
            new Claim(ClaimTypes.NameIdentifier, usuario.SegUsuarioId.ToString()),
            new Claim(ClaimTypes.Name, usuario.NombreUsuario),
            new Claim("nombre_completo", usuario.NombresApellidos)
        };

        var credentials = new SigningCredentials(
            new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key)),
            SecurityAlgorithms.HmacSha256);

        var jwt = new JwtSecurityToken(
            issuer,
            audience,
            claims,
            expires: expiraEn,
            signingCredentials: credentials);

        return (new JwtSecurityTokenHandler().WriteToken(jwt), expiraEn);
    }
}

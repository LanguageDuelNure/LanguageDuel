using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using LanguageDuel.Application.Services;
using LanguageDuel.Infrastructure.Options;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;

namespace LanguageDuel.Infrastructure.Services;

public class JwtTokenService(IOptions<JwtTokenOptions> jwtBearerOptions) : IJwtTokenService
{
    private readonly JwtTokenOptions _jwtTokenOptions = jwtBearerOptions.Value;

    public string GenerateToken(string userId, string role)
    {
        SecurityTokenDescriptor descriptor = new()
        {
            Subject = new ClaimsIdentity(
            [
                new(ClaimTypes.NameIdentifier, userId),
                new(ClaimTypes.Role, role)
            ]),
            Issuer = _jwtTokenOptions.Issuer,
            Audience = _jwtTokenOptions.Audience,
            Expires = DateTime.UtcNow.AddDays(_jwtTokenOptions.ExpiresDay),
            SigningCredentials = new SigningCredentials(
                new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtTokenOptions.Key)),
                SecurityAlgorithms.HmacSha256)
        };

        JwtSecurityTokenHandler handler = new();
        var token = handler.CreateToken(descriptor);
        return handler.WriteToken(token);
    }
}

namespace LanguageDuel.Application.Services;

public interface IJwtTokenService
{
    string GenerateToken(string userId, string role);
}
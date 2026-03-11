namespace LanguageDuel.Application.Dtos.Users;

public class LoginResultDto
{
    public bool EmailConfirmed { get; set; }
    public Guid UserId { get; set; }
    public string Role { get; set; } = string.Empty;
    public string? JwtToken { get; set; }
}
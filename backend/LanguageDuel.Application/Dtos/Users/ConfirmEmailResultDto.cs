namespace LanguageDuel.Application.Dtos.Users;

public class ConfirmEmailResultDto
{
    public string Role { get; set; } = string.Empty;
    public string JwtToken { get; set; } = string.Empty;
}

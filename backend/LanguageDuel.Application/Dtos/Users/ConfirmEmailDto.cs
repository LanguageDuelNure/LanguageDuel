namespace LanguageDuel.Application.Dtos.Users;

public class ConfirmEmailDto
{
    public string Code { get; set; } = string.Empty;
    public string UserId { get; set; } = string.Empty;
}
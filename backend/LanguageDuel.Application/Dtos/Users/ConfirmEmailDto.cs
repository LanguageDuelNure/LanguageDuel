namespace LanguageDuel.Application.Dtos.Users;

public class ConfirmEmailDto
{
    public string Code { get; set; } = string.Empty;
    public Guid UserId { get; set; }
}
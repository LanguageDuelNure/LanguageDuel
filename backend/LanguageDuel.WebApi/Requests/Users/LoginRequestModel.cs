using System.ComponentModel.DataAnnotations;
using LanguageDuel.WebApi.ValidationAttributes;

namespace LanguageDuel.WebApi.Requests.Users;

public class LoginRequestModel
{
    [RequiredWithCode]
    [EmailAddress]
    [StringLengthWithCode(254, MinimumLength = 5)]
    public string Email { get; set; } = string.Empty;

    [RequiredWithCode]
    [StringLengthWithCode(128, MinimumLength = 8)]
    [StrongPasswordWithCode]
    public string Password { get; set; } = string.Empty;
}

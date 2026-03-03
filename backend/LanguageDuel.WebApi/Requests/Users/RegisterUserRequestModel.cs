using LanguageDuel.WebApi.ValidationAttributes;

namespace LanguageDuel.WebApi.Requests.Users;

public class RegisterUserRequestModel
{
    [RequiredWithCode]
    [EmailAddressWithCode]
    [StringLengthWithCode(254, MinimumLength = 5)]
    public string Email { get; set; } = string.Empty;

    [RequiredWithCode]
    [StringLengthWithCode(128, MinimumLength = 8)]
    [StrongPasswordWithCode]
    public string Password { get; set; } = string.Empty;

    [RequiredWithCode]
    [CompareWithCode(nameof(Password))]
    public string ConfirmPassword { get; set; } = string.Empty;

    [RequiredWithCode]
    [StringLengthWithCode(32, MinimumLength = 3)]
    public string Name { get; set; } = string.Empty;
}

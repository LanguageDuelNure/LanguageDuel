using System.ComponentModel.DataAnnotations;
using LanguageDuel.WebApi.ValidationAttributes;

namespace LanguageDuel.WebApi.Requests.Users;

public class LoginRequestModel
{
    [Required]
    [EmailAddress]
    [StringLengthWithCode(254, MinimumLength = 5)]
    public string Email { get; set; } = string.Empty;

    [Required]
    [StringLengthWithCode(128, MinimumLength = 8)]
    [RegularExpression("^(?=.*[a-z])(?=.*[A-Z]).*$", ErrorMessage = "Password must have at least one lowercase and one upperrcase letter")]
    public string Password { get; set; } = string.Empty;
}

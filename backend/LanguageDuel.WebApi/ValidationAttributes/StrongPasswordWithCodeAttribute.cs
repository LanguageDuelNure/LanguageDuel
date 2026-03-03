using System.ComponentModel.DataAnnotations;
using System.Text.Json;
using LanguageDuel.Application.Dtos.Results;

namespace LanguageDuel.WebApi.ValidationAttributes;

[AttributeUsage(AttributeTargets.Property, AllowMultiple = false)]
public class StrongPasswordWithCodeAttribute : ValidationAttribute
{
    private const string _regularExpressionPattern = "^(?=.*[a-z])(?=.*[A-Z]).*$";
    private static readonly RegularExpressionAttribute _regularExpressionAttribute = new(_regularExpressionPattern);
    protected override ValidationResult? IsValid(object? value, ValidationContext validationContext)
    {
        if (_regularExpressionAttribute.IsValid(value))
        {
            return ValidationResult.Success;
        }

        var error = new Error
        {
            Field = validationContext.MemberName ?? string.Empty,
            Key = ErrorKey.Incorrect,
            Message = "Password must have at least one lowercase and one upperrcase letter",
            Parameters = new Dictionary<string, object>
            {
                { "MinNumberOfUppercaseCharacters", 1 },
                { "MinNumberOfLowercaseCharacters", 1 },
            }
        };

        return new ValidationResult(JsonSerializer.Serialize(error));
    }
}
using System.ComponentModel.DataAnnotations;
using System.Text.Json;
using LanguageDuel.Application.Dtos.Results;

namespace LanguageDuel.WebApi.ValidationAttributes;

[AttributeUsage(AttributeTargets.Property, AllowMultiple = false)]
public class EmailAddressWithCodeAttribute : ValidationAttribute
{
    private static readonly EmailAddressAttribute _emailAddressAttribute = new();
    protected override ValidationResult? IsValid(object? value, ValidationContext validationContext)
    {
        if (_emailAddressAttribute.IsValid(value))
        {
            return ValidationResult.Success;
        }

        var error = new Error
        {
            Field = validationContext.MemberName ?? string.Empty,
            Key = ErrorKey.Incorrect,
            Message = ErrorMessage ?? $"Invalid email address."
        };

        return new ValidationResult(JsonSerializer.Serialize(error));
    }
}
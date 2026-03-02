using System.ComponentModel.DataAnnotations;
using System.Text.Json;
using LanguageDuel.Application.Dtos.Results;

namespace LanguageDuel.WebApi.ValidationAttributes;

[AttributeUsage(AttributeTargets.Property, AllowMultiple = false)]
public class StringLengthWithCodeAttribute(int maximumLength) : StringLengthAttribute(maximumLength)
{
    protected override ValidationResult? IsValid(object? value, ValidationContext validationContext)
    {
        var baseResult = base.IsValid(value, validationContext);

        if (baseResult == ValidationResult.Success)
        {
            return ValidationResult.Success;
        }

        var error = new Error
        {
            Field = validationContext.MemberName ?? string.Empty,
            Key = ErrorKey.InvalidStringLength,
            Message = ErrorMessage ?? $"The string length must be between {MinimumLength} and {MaximumLength} characters.",
            Parameters = new Dictionary<string, object>
            {
                { "Max", MaximumLength },
                { "Min", MinimumLength }
            }
        };

        return new ValidationResult(JsonSerializer.Serialize(error), baseResult?.MemberNames);
    }
}
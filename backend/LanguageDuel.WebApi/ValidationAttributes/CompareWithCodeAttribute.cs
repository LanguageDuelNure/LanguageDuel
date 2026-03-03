using System.ComponentModel.DataAnnotations;
using System.Text.Json;
using LanguageDuel.Application.Dtos.Results;

namespace LanguageDuel.WebApi.ValidationAttributes;

[AttributeUsage(AttributeTargets.Property, AllowMultiple = false)]
public class CompareWithCodeAttribute(string otherProperty) : CompareAttribute(otherProperty)
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
            Key = ErrorKey.DoNotMatch,
            Message = ErrorMessage ?? $"Values do not match.",
            Parameters = new Dictionary<string, object>
            {
                { "OtherProperty", OtherProperty }
            }
        };

        return new ValidationResult(JsonSerializer.Serialize(error), baseResult?.MemberNames);
    }
}
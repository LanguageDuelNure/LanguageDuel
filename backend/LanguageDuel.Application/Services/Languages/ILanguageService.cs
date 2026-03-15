using LanguageDuel.Application.Dtos.Languages;
using LanguageDuel.Application.Dtos.Results;

namespace LanguageDuel.Application.Services.Languages;

public interface ILanguageService
{
    Task<Result<IEnumerable<LanguageDto>>> GetLanguagesAsync(Guid userId);
}
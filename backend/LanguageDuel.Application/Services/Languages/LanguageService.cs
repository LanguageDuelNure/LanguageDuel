using AutoMapper;
using LanguageDuel.Application.Dtos.Languages;
using LanguageDuel.Application.Dtos.Results;
using LanguageDuel.Application.Repositories;

namespace LanguageDuel.Application.Services.Languages;

public class LanguageService(ILanguageRepository languageRep, IMapper mapper) : ILanguageService
{
    public async Task<Result<IEnumerable<LanguageDto>>> GetLanguagesAsync(Guid userId)
    {
        var languages = await languageRep.GetLanguagesWithRatingAsync(userId);
        return new Result<IEnumerable<LanguageDto>>()
        {
            Value = mapper.Map<IEnumerable<LanguageDto>>(languages)
        };
    }
}
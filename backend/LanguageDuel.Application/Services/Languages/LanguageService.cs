using AutoMapper;
using LanguageDuel.Application.Dtos.Languages;
using LanguageDuel.Application.Dtos.Results;
using LanguageDuel.Application.Repositories;
using LanguageDuel.Domain;

namespace LanguageDuel.Application.Services.Languages;

public class LanguageService (IRepository<Language> languageRep, IMapper mapper) : ILanguageService
{
    public async Task<Result<IEnumerable<LanguageDto>>> GetLanguagesAsync()
    {
        var languages = await languageRep.GetAllAsync();
        return new Result<IEnumerable<LanguageDto>>()
        {
            Value = mapper.Map<IEnumerable<LanguageDto>>(languages)
        };
    }
}
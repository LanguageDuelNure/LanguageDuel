using AutoMapper;
using LanguageDuel.Application.Dtos.Languages;
using LanguageDuel.Domain;

namespace LanguageDuel.Application.Profiles;

public class LanguageProfile : Profile
{
    public LanguageProfile()
    {
        CreateMap<Language, LanguageDto>();
    }
}
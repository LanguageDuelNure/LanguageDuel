using AutoMapper;
using LanguageDuel.Application.Dtos.UserLanguages;
using LanguageDuel.Domain.Entities;

namespace LanguageDuel.Application.Profiles;

public class UserLanguageProfile : Profile
{
    public UserLanguageProfile()
    {
        CreateMap<ApplicationUserLanguage, UserLanguageDto>();
    }
}
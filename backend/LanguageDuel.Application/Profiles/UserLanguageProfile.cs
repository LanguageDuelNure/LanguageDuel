using AutoMapper;
using LanguageDuel.Application.Dtos.UserLanguages;
using LanguageDuel.Application.Dtos.Users;
using LanguageDuel.Domain.Entities;

namespace LanguageDuel.Application.Profiles;

public class UserLanguageProfile : Profile
{
    public  UserLanguageProfile()
    {
        CreateMap<ApplicationUserLanguage, UserLanguageDto>();
    }
}
using AutoMapper;
using LanguageDuel.Application.Dtos.Languages;
using LanguageDuel.Domain.Entities;

namespace LanguageDuel.Application.Profiles;

public class LanguageProfile : Profile
{
    public LanguageProfile()
    {
        CreateMap<Language, LanguageDto>()
            .ForMember(dest => dest.Rating,
                opt => opt.MapFrom(src => src.ApplicationUserLanguages.FirstOrDefault().Rating));
    }
}
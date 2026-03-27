using AutoMapper;
using LanguageDuel.Application.Dtos.Users;
using LanguageDuel.Domain.Entities;

namespace LanguageDuel.Application.Profiles;

public class UserProfile : Profile
{
    public UserProfile()
    {
        CreateMap<ApplicationUser, UserDto>()
            .ForMember(dest => dest.LanguageRatings, 
                opt => opt.MapFrom(src => src.ApplicationUserLanguages))
            .ForMember(dest => dest.UserOpponents, 
                opt => opt.MapFrom(src => 
                    src.ApplicationUserOpponents
                    .Concat(src.OpponentApplicationUsers)
                    .ToList()));
    }
}
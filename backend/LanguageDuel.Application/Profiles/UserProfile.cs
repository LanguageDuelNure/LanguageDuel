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

        CreateMap<ApplicationUser, UserAdminListItemDto>()
            .ForMember(dest => dest.RemainingBanDuration, opt => opt.MapFrom(src => 
                src.LockoutEnd.HasValue && src.LockoutEnd.Value > DateTimeOffset.UtcNow 
                    ? src.LockoutEnd.Value - DateTimeOffset.UtcNow 
                    : (TimeSpan?)null));
        
        CreateMap<ApplicationUser, LeaderboardItemDto>()
            .ForMember(dest => dest.Rank, opt => opt.MapFrom(src => 
                src.ApplicationUserLanguages.OrderByDescending(ul => ul.Rating).FirstOrDefault().Rating))
            .ForMember(dest => dest.TotalGames, opt => opt.MapFrom(src => 
                src.ApplicationUserLanguages.OrderByDescending(ul => ul.Rating).FirstOrDefault().TotalGames))
            .ForMember(dest => dest.TotalWins, opt => opt.MapFrom(src => 
                src.ApplicationUserLanguages.OrderByDescending(ul => ul.Rating).FirstOrDefault().TotalWins))
            .ForMember(dest => dest.Language, opt => opt.MapFrom(src => 
                src.ApplicationUserLanguages.OrderByDescending(ul => ul.Rating).FirstOrDefault().Language.Name));
    }
}
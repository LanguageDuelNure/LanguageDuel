using AutoMapper;
using LanguageDuel.Application.Dtos.Users;
using LanguageDuel.Domain.Entities;

namespace LanguageDuel.Application.Profiles;

public class UserOpponentProfile : Profile
{
    public UserOpponentProfile()
    {
        CreateMap<ApplicationUserOpponent, UserOpponentDto>();
    }
}
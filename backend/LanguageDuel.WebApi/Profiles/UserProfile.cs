using AutoMapper;
using LanguageDuel.Application.Dtos.Users;
using LanguageDuel.WebApi.Requests.Users;

namespace LanguageDuel.WebApi.Profiles;

public class UserProfile : Profile
{
    public UserProfile()
    {
        CreateMap<RegisterUserRequestModel, RegisterUserDto>();
        CreateMap<ConfirmEmailDto, EmailConfirmationRequestModel>();
        CreateMap<EmailConfirmationRequestModel, ConfirmEmailDto>();
        CreateMap<LoginRequestModel, LoginUserDto>();
    }
}

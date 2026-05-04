using AutoMapper;
using LanguageDuel.Application.Dtos.Tickets;
using LanguageDuel.Application.Dtos.Users;
using LanguageDuel.WebApi.Requests.Tickets;

namespace LanguageDuel.WebApi.Profiles;

public class TicketProfile : Profile
{
    public TicketProfile()
    {
        CreateMap<CreateTicketRequestModel, CreateTicketDto>();
        CreateMap<ReplyToTicketRequestModel, ReplyToTicketDto>();
    }
}
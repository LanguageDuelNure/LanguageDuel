using AutoMapper;
using LanguageDuel.Application.Dtos.Tickets;
using LanguageDuel.Domain.Entities;

namespace LanguageDuel.Application.Profiles;

public class TicketProfile : Profile
{
    public TicketProfile()
    {
        CreateMap<Ticket, TicketListItemDto>()
            .ForMember(dest => dest.LastMessage, 
                opt => opt.MapFrom(src 
                    => src.Messages
                        .OrderByDescending(m => m.CreatedAt)
                        .FirstOrDefault()!
                        .Message))
            .ForMember(dest => dest.CreatedAt, 
                opt => opt.MapFrom(src 
                    => src.Messages
                        .OrderBy(m => m.CreatedAt)
                        .FirstOrDefault()!
                        .CreatedAt))
            .ForMember(dest => dest.UserId,
                opt => opt.MapFrom(src
                    => src.ApplicationUserId));

        CreateMap<Ticket, TicketDto>()
            .ForMember(dest => dest.CreatedAt,
                opt => opt.MapFrom(src
                    => src.Messages
                        .OrderBy(m => m.CreatedAt)
                        .FirstOrDefault()!
                        .CreatedAt))
            .ForMember(dest => dest.UserId,
                opt => opt.MapFrom(src
                => src.ApplicationUserId));
        CreateMap<TicketMessage, TicketMessageDto>()
            .ForMember(dest => dest.UserId,
                opt => opt.MapFrom(src
                    => src.ApplicationUserId));
    }
}
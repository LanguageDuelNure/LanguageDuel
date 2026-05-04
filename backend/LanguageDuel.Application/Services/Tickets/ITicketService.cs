using LanguageDuel.Application.Dtos.Results;
using LanguageDuel.Application.Dtos.Tickets;
using LanguageDuel.Application.Dtos.Users;

namespace LanguageDuel.Application.Services.Tickets;

public interface ITicketService
{
    Task<Result<CreateTicketDto>> CreateTicketAsync(Guid userId, CreateTicketDto dto);
    Task<Result<IEnumerable<TicketListItemDto>>> GetTicketsByUserAsync(Guid userId);
    Task<Result<TicketDto>> GetTicketAsync(Guid userId, Guid ticketId);
    Task<Result> ReplyToTicketAsync(Guid adminId, ReplyToTicketDto dto);
    Task<Result<IEnumerable<TicketListItemDto>>> GetOpenTicketsAsync();
    Task<Result> CloseTicketAsync(Guid ticketId);
    Task<Result<IEnumerable<TicketListItemDto>>> GetInProgressTicketsAsync();
    Task<Result<IEnumerable<TicketListItemDto>>> GetClosedTicketsAsync();
}
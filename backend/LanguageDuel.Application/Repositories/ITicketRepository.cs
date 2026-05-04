using LanguageDuel.Domain.Entities;

namespace LanguageDuel.Application.Repositories;

public interface ITicketRepository : IRepository<Ticket>
{
    Task<IEnumerable<Ticket>> GetTicketsByUserAsync(Guid userId);
    Task<Ticket?> GetTicketAsync(Guid ticketId);
    Task<IEnumerable<Ticket>> GetTicketsAsync(IEnumerable<TicketStatus> ticketStatuses);
}
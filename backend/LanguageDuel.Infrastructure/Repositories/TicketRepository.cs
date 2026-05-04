using LanguageDuel.Application.Repositories;
using LanguageDuel.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace LanguageDuel.Infrastructure.Repositories;

public class TicketRepository(ApplicationDbContext dbContext) : Repository<Ticket>(dbContext), ITicketRepository
{
    public async Task<IEnumerable<Ticket>> GetTicketsByUserAsync(Guid userId)
    {
        return await DbSet
            .Where(t => t.ApplicationUserId == userId)
            .Include(t => t.Messages)
            .ToListAsync();
    }
    
    public async Task<Ticket?> GetTicketAsync(Guid ticketId)
    {
        return await DbSet
            .Where(t => t.Id == ticketId)
            .Include(t => t.Messages)
            .FirstOrDefaultAsync();
    }
    
    public async Task<IEnumerable<Ticket>> GetTicketsAsync(IEnumerable<TicketStatus> ticketStatuses)
    {
        var ticketStatusesList = ticketStatuses.ToList();
        return await DbSet
            .Where(t => ticketStatusesList.Count == 0 || ticketStatusesList.Contains(t.Status))
            .Include(t => t.Messages)
            .ToListAsync();
    }
}
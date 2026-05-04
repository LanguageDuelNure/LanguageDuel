using LanguageDuel.Application.Repositories;
using LanguageDuel.Domain.Entities;

namespace LanguageDuel.Infrastructure.Repositories;

public class TicketMessageRepository(ApplicationDbContext dbContext) : Repository<TicketMessage>(dbContext), ITicketMessageRepository
{
    
}
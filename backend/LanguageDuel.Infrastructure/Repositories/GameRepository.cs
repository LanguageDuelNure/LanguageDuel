using LanguageDuel.Application.Repositories;
using LanguageDuel.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace LanguageDuel.Infrastructure.Repositories;

public class GameRepository(ApplicationDbContext dbContext) : Repository<Game>(dbContext), IGameRepository
{
    public async Task<Game?> GetGameByIdAsync(Guid gameId)
    {
        return await DbSet
            .Where(g => g.Id == gameId)
            .Include(g => g.DifficultyLevel)
            .Include(g => g.Language)
            .Include(g => g.GameApplicationUsers)
            .ThenInclude(q => q.ApplicationUser)
            .Include(g => g.GameQuestions)
            .ThenInclude(q => q.Question)
            .Include(g => g.GameQuestions)
            .ThenInclude(q => q.GameAnswers)
            .ThenInclude(q => q.Answer)
            .FirstOrDefaultAsync();
    }
    
    public async Task<IEnumerable<Game>> GetGamesByUserAsync(Guid userId)
    {
        return await DbSet
            .Where(g => g.GameApplicationUsers.Any(gu => gu.ApplicationUserId == userId))
            .Include(g => g.DifficultyLevel)
            .Include(g => g.Language)
            .Include(g => g.GameApplicationUsers)
            .ThenInclude(q => q.ApplicationUser)
            .Include(g => g.GameQuestions)
            .OrderByDescending(g => g.CreatedAt)
            .ToListAsync();
    }
}
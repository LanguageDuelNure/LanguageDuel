using LanguageDuel.Application.Repositories;
using LanguageDuel.Domain;
using LanguageDuel.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace LanguageDuel.Infrastructure.Repositories;

public class DifficultyRepository(ApplicationDbContext dbContext) : Repository<DifficultyLevel>(dbContext), IDifficultyRepository
{
    public async Task<DifficultyLevel> GetDifficultyLevelByRatingAsync(int rating)
    {
        return await DbSet
            .OrderBy(dl => dl.StartRating)
            .Where(dl => dl.StartRating <= rating)
            .FirstOrDefaultAsync();
    }
}
using LanguageDuel.Application.Repositories;
using LanguageDuel.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace LanguageDuel.Infrastructure.Repositories;

public class LanguageRepository(ApplicationDbContext dbContext) : Repository<Language>(dbContext), ILanguageRepository
{
    public async Task<IEnumerable<Language>> GetLanguagesWithRatingAsync(Guid userId)
    {
        return await DbSet
            .Include(l => l.ApplicationUserLanguages
                .Where(aul => aul.ApplicationUserId == userId))
            .ToListAsync();
    }
}
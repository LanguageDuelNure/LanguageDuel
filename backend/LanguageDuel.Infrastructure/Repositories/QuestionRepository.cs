using LanguageDuel.Application.Repositories;
using LanguageDuel.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace LanguageDuel.Infrastructure.Repositories;

public class QuestionRepository(ApplicationDbContext dbContext) : Repository<Question>(dbContext), IQuestionRepository
{
    public async Task<IEnumerable<Question>> GetRandomQuestionsAsync(Guid languageId, Guid difficultyLevelId, int questionCount)
    {
        return await DbSet
            .AsNoTracking()
            .Where(q => q.LanguageId == languageId && q.DifficultyLevelId == difficultyLevelId)
            .OrderBy(q => EF.Functions.Random())
            .Take(questionCount)
            .Include(q => q.Answers)
            .ToListAsync();
    }
}
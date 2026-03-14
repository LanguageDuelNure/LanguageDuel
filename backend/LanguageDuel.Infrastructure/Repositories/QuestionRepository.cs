using LanguageDuel.Application.Repositories;
using LanguageDuel.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace LanguageDuel.Infrastructure.Repositories;

public class QuestionRepository(ApplicationDbContext dbContext) : Repository<Question>(dbContext), IQuestionRepository
{
    public async Task<IEnumerable<Question>> GetRandomQuestionsAsync(Guid languageId, Guid difficultyLevelId, int questionCount)
    {
        var random = new Random();
        return await DbSet
            .Where(q => q.LanguageId == languageId && q.DifficultyLevelId == difficultyLevelId)
            .OrderBy(q => random.Next())
            .Take(questionCount)
            .Include(q => q.Answers)
            .ToListAsync();
    }
}
using LanguageDuel.Domain.Entities;

namespace LanguageDuel.Application.Repositories;

public interface IDifficultyRepository
{
    Task<DifficultyLevel> GetDifficultyLevelByRatingAsync(int rating);
}
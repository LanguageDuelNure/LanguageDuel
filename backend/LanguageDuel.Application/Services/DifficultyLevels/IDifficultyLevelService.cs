using LanguageDuel.Application.Dtos.Results;
using LanguageDuel.Domain.Entities;

namespace LanguageDuel.Application.Services.DifficultyLevels;

public interface IDifficultyLevelService
{
    Task<Result<IEnumerable<DifficultyLevel>>> GetDifficultyLevelsAsync();
}
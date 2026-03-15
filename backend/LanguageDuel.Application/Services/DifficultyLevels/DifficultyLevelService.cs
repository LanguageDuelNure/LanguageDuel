using AutoMapper;
using LanguageDuel.Application.Dtos.Results;
using LanguageDuel.Application.Repositories;
using LanguageDuel.Domain.Entities;

namespace LanguageDuel.Application.Services.DifficultyLevels;

public class DifficultyLevelService(IRepository<DifficultyLevel> difficultyLevelRep, IMapper mapper) : IDifficultyLevelService
{
    public async Task<Result<IEnumerable<DifficultyLevel>>> GetDifficultyLevelsAsync()
    {
        var difficultyLevels = await difficultyLevelRep.GetAllAsync();
        return new Result<IEnumerable<DifficultyLevel>>()
        {
            Value = mapper.Map<IEnumerable<DifficultyLevel>>(difficultyLevels),
        };
    }
}
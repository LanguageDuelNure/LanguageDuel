using LanguageDuel.Application.Dtos.Games;
using LanguageDuel.Application.Dtos.Results;

namespace LanguageDuel.Application.Services.ApplicationUserLanguages;

public interface IApplicationUserLanguageService
{
    Task<Result> UpdateStatisticsAsync(Guid userId, Guid languageId, int ratingChange);
    Task<Result> UpdateTotalGamesAsync(Guid userId, Guid languageId);
}
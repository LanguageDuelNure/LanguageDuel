using LanguageDuel.Application.Dtos.Games;
using LanguageDuel.Application.Dtos.Results;

namespace LanguageDuel.Application.Services.ApplicationUserLanguages;

public interface IApplicationUserLanguageService
{
    Task<Result> ChangeUsersRatingAsync(Guid userId, Guid languageId, int ratingChange);
}
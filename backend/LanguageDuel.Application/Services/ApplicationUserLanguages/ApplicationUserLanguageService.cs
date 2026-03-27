using LanguageDuel.Application.Dtos.Results;
using LanguageDuel.Application.Repositories;
using LanguageDuel.Domain.Entities;

namespace LanguageDuel.Application.Services.ApplicationUserLanguages;

public class ApplicationUserLanguageService(IUnitOfWork unitOfWork, IRepository<ApplicationUserLanguage> applicationUserLanguageRep, IUserService userService) : IApplicationUserLanguageService
{
    public async Task<Result> UpdateStatisticsAsync(Guid userId, Guid languageId, int ratingChange)
    {
        var isWin = ratingChange > 0;
        
        var applicationUserLanguage = await applicationUserLanguageRep.GetAsync(userId, languageId);

        if (applicationUserLanguage == null)
        {
            applicationUserLanguageRep.Add(new ApplicationUserLanguage
            {
                ApplicationUserId = userId,
                LanguageId = languageId,
                Rating = isWin ? ratingChange : 0,
                TotalGames = 1,
                TotalWins = isWin ? 1 : 0,
                MaxRating =  isWin ? ratingChange : 0
            });
        }
        else
        {
            applicationUserLanguage.TotalGames++;
            if (applicationUserLanguage.Rating + ratingChange < 0)
            {
                applicationUserLanguage.Rating = 0;
            }
            else
            {
                applicationUserLanguage.Rating += ratingChange;
                if (isWin)
                {
                    applicationUserLanguage.TotalWins++;
                }
                if (applicationUserLanguage.Rating > applicationUserLanguage.MaxRating)
                {
                    applicationUserLanguage.MaxRating = applicationUserLanguage.Rating;
                }
            }
        }

        return new Result();
    }

    public async Task<Result> UpdateTotalGamesAsync(Guid userId, Guid languageId)
    {
        var applicationUserLanguage = await applicationUserLanguageRep.GetAsync(userId, languageId);
        
        applicationUserLanguage.TotalGames++;
        
        return new Result();
    }
}
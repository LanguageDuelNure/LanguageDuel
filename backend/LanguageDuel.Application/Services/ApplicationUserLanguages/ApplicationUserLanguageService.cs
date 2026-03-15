using LanguageDuel.Application.Dtos.Results;
using LanguageDuel.Application.Repositories;
using LanguageDuel.Domain.Entities;

namespace LanguageDuel.Application.Services.ApplicationUserLanguages;

public class ApplicationUserLanguageService(IUnitOfWork unitOfWork, IRepository<ApplicationUserLanguage> applicationUserLanguageRep) : IApplicationUserLanguageService
{
    public async Task<Result> ChangeUsersRatingAsync(Guid userId, Guid languageId, int ratingChange)
    {
        var applicationUserLanguage = await applicationUserLanguageRep.GetAsync(userId, languageId);

        if (applicationUserLanguage == null)
        {
            applicationUserLanguageRep.Add(new ApplicationUserLanguage
            {
                ApplicationUserId = userId,
                LanguageId = languageId,
                Rating = ratingChange < 0 ? 0 : ratingChange,
            });
        }
        else
        {
            if (applicationUserLanguage.Rating + ratingChange < 0)
            {
                applicationUserLanguage.Rating = 0;
            }
            else
            {
                applicationUserLanguage.Rating += ratingChange;
            }
        }

        await unitOfWork.CommitAsync();

        return new Result();
    }
}
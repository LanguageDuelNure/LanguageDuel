using LanguageDuel.Application.Dtos.Results;
using LanguageDuel.Application.Repositories;
using LanguageDuel.Domain.Entities;

namespace LanguageDuel.Application.Services.ApplicationUserOpponents;

public class ApplicationUserOpponentService(IRepository<ApplicationUserOpponent> appUserOpponentRep) : IApplicationUserOpponentService
{
    public async Task<Result> UpdateStatisticsAsync(Guid userId1, Guid userId2)
    {
        var userOpponent = await appUserOpponentRep.GetAsync(userId1, userId2);
        if (userOpponent == null)
        {
            userOpponent = await appUserOpponentRep.GetAsync(userId2, userId1);
            if (userOpponent == null)
            {
                userOpponent = new ApplicationUserOpponent
                {
                    ApplicationUserId = userId1,
                    OpponentId = userId2,
                };
                appUserOpponentRep.Add(userOpponent);
            }
        }

        userOpponent.MatchesPlayed++;
        userOpponent.LastPlayedAt = DateTime.UtcNow;

        return new Result();
    }
}
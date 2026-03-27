using LanguageDuel.Application.Dtos.Results;

namespace LanguageDuel.Application.Services.ApplicationUserOpponents;

public interface IApplicationUserOpponentService
{
    Task<Result> UpdateStatisticsAsync(Guid userId1, Guid userId2);
}
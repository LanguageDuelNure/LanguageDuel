using LanguageDuel.Application.Dtos.Results;

namespace LanguageDuel.Application.Services.Games;

public interface IGameService
{
    Task<Result> SendGameInvitationsAsync(Guid userId, Guid languageId);
}
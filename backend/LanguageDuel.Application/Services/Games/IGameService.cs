using LanguageDuel.Application.Dtos.Results;

namespace LanguageDuel.Application.Services.Games;

public interface IGameService
{
    Task<Result> SendGameInvitationsAsync(Guid userId, Guid languageId);
    Task<IEnumerable<string>> GetSearchGroupsAsync(Guid userId, Guid languageId);
    string GetGameGroupAsync(Guid gameId);
}
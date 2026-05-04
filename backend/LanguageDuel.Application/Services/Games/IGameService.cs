using LanguageDuel.Application.Dtos.Games;
using LanguageDuel.Application.Dtos.Results;

namespace LanguageDuel.Application.Services.Games;

public interface IGameService
{
    Task<IEnumerable<string>> GetSearchGroupsAsync(Guid userId, Guid languageId);
    string GetGameGroupAsync(Guid gameId);
    Task<Result> ChooseAnswerAsync(Guid userId, Guid gameId, Guid answerId);
    Task<Result> RemoveFromSearchGroupsAsync(Guid userId, Guid languageId);
    Result<Guid> GetGame(Guid userId);
    Task<Result> SendGameStateAsync(Guid gameId);
    Task<Result> SendGameInvitationsAsync(Guid userId, Guid languageId);
    Task<Result> GiveUpAsync(Guid userId, Guid gameId);
    Task<Result<IEnumerable<GameResultListItemDto>>> GetGamesHistory(Guid userId);
    Task<Result<GameResultDto>> GetGameHistory(Guid userId, Guid gameId);
}
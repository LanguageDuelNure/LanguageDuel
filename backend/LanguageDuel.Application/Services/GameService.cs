using System.Collections.Concurrent;
using LanguageDuel.Application.Dtos.Games;
using LanguageDuel.Application.Dtos.Results;

namespace LanguageDuel.Application.Services;

public class GameService(IGameNotificationService gameNotificationService) : IGameService
{
    private readonly ConcurrentDictionary<Guid, GameSessionDto> _games = new();
    public async Task<Result> SendGameInvitationsAsync(Guid userId)
    {
        await gameNotificationService.SendGameInvitationAsync(userId, 0, 10);
        return new Result();
    }
}
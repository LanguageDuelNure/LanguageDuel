using System.Collections.Concurrent;
using LanguageDuel.Application.Dtos.Games;

namespace LanguageDuel.Application.Services.Games;

public class GameSessionStorage : IGameSessionStorage
{
    public ConcurrentDictionary<Guid, GameSessionDto> Games { get; } = new();
    public ConcurrentDictionary<string, GameInvitationDto> SearchGroups { get; } = new();
    public SemaphoreSlim MatchmakingLock { get; } = new(1, 1);
}
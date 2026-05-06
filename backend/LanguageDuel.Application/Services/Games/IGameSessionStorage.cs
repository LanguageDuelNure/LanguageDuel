using System.Collections.Concurrent;
using LanguageDuel.Application.Dtos.Games;

namespace LanguageDuel.Application.Services.Games;

public interface IGameSessionStorage
{
    ConcurrentDictionary<Guid, GameSessionDto> Games { get; }
    ConcurrentDictionary<string, GameInvitationDto> SearchGroups { get; }
    SemaphoreSlim MatchmakingLock { get; }
}
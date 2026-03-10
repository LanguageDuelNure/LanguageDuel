using LanguageDuel.Application.Dtos.Results;

namespace LanguageDuel.Application.Services;

public interface IGameService
{
    Task<Result> SendGameInvitationsAsync(Guid userId);
}
using LanguageDuel.Application.Dtos.Results;
using LanguageDuel.Application.Services.Games;
using Microsoft.AspNetCore.SignalR;

namespace LanguageDuel.Infrastructure.Hubs;

public class GameHub(IGameService gameService) : Hub
{
    public async Task<Result> StartSearchGameAsync(Guid userId, Guid languageId)
    {
        var groups = await gameService.GetSearchGroupsAsync(userId, languageId);

        var tasks = groups
            .Select(g => Groups
                .AddToGroupAsync(
                    Context.ConnectionId,
                    g));

        await Task.WhenAll(tasks);

        return new Result();
    }

    public async Task<Result> StopSearchGameAsync(Guid userId, Guid languageId)
    {
        var groups = await gameService.GetSearchGroupsAsync(userId, languageId);

        var tasks = groups
            .Select(g => Groups.RemoveFromGroupAsync(
                Context.ConnectionId,
                g));

        await Task.WhenAll(tasks);

        return new Result();
    }

    public async Task<Result> AddToGameAsync(Guid gameId)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, gameService.GetGameGroupAsync(gameId));

        return new Result();
    }

    public async Task<Result> LeaveGameAsync(Guid gameId)
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, gameService.GetGameGroupAsync(gameId));
        return new Result();
    }
}
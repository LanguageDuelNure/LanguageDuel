using LanguageDuel.Application.Dtos.Results;
using LanguageDuel.Application.Services;
using Microsoft.AspNetCore.SignalR;

namespace LanguageDuel.Infrastructure.Hubs;

public class GameHub(IUserService userService) : Hub
{
    public async Task<Result> StartSearchGameAsync(Guid userId)
    {
        var result = await userService.GetRatingRangeAsync(userId);
        if (!result.IsSuccess)
        {
            return  result;
        }
        
        var range = result.Value;

        var tasks = Enumerable
            .Range(range.StartRange, range.Count)
            .Select(i => Groups.AddToGroupAsync(Context.ConnectionId, i.ToString()));

        await Task.WhenAll(tasks);
        
        return new Result();
    }

    public async Task<Result> StopSearchGameAsync(Guid userId)
    {
        var result = await userService.GetRatingRangeAsync(userId);
        if (!result.IsSuccess)
        {
            return  result;
        }
        
        var range = result.Value;

        var tasks = Enumerable
            .Range(range.StartRange, range.Count)
            .Select(i => Groups.RemoveFromGroupAsync(Context.ConnectionId, i.ToString()));

        await Task.WhenAll(tasks);
        
        return new Result();
    }
    
    public async Task AddToGameAsync(Guid gameId)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, "game-id-" + gameId.ToString());
    }
}
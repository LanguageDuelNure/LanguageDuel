using LanguageDuel.Application.Services;
using LanguageDuel.Infrastructure.Hubs;
using Microsoft.AspNetCore.SignalR;

namespace LanguageDuel.Infrastructure.Services;

public class GameNotificationService(IHubContext<GameHub> hubContext) : IGameNotificationService
{
    public async Task SendGameInvitationAsync(Guid userId, int startRange, int count)
    {
        var tasks = Enumerable
                .Range(startRange, count)
                .Select(i => hubContext.Clients.Group(i.ToString())
                .SendAsync("ReceiveGameInvitation", userId, startRange));
        
        await Task.WhenAll(tasks);
    }
}
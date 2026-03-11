using LanguageDuel.Application.Services;
using LanguageDuel.Infrastructure.Hubs;
using Microsoft.AspNetCore.SignalR;

namespace LanguageDuel.Infrastructure.Services;

public class NotificationService(IHubContext<GameHub> hubContext) : INotificationService
{
    public async Task SendNotificationAsync(string groupName, string message, object? args)
    {
        await hubContext.Clients
            .Group(groupName)
            .SendAsync(message, args);
    }
}
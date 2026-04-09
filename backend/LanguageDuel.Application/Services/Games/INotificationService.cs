namespace LanguageDuel.Application.Services;

public interface INotificationService
{
    Task SendNotificationAsync(string groupName, string message, object? args);
    Task SendNotificationToUserAsync(string userId, string message, object? args);
}
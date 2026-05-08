namespace LanguageDuel.Application.Services.Games;

public interface INotificationService
{
    Task SendNotificationAsync(string groupName, string message, object? args);
}
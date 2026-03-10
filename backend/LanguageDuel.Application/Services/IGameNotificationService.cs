namespace LanguageDuel.Application.Services;

public interface IGameNotificationService
{
    Task SendGameInvitationAsync(Guid userId, int startRange, int count);
}
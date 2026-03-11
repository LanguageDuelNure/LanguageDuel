namespace LanguageDuel.Application.Dtos.Games;

public class GameInvitationDto
{
    public Guid InviterUserId { get; set; }
    
    public Guid GameId { get; set; }
}
namespace LanguageDuel.Application.Dtos.Users;

public class UserOpponentDto
{
    public Guid UserId { get; set; }

    public string Name { get; set; }

    public int MatchesPlayed { get; set; }

    public DateTime LastPlayedAt { get; set; }
}
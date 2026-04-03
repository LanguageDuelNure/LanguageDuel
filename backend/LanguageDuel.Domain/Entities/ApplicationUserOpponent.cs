namespace LanguageDuel.Domain.Entities;

public class ApplicationUserOpponent
{
    public Guid ApplicationUserId { get; set; }

    public ApplicationUser ApplicationUser { get; set; }

    public Guid OpponentId { get; set; }

    public ApplicationUser Opponent { get; set; }

    public int MatchesPlayed { get; set; }

    public DateTime LastPlayedAt { get; set; }
}
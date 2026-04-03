namespace LanguageDuel.Domain.Entities;

public class ApplicationUserLanguage
{
    public Guid ApplicationUserId { get; set; }

    public ApplicationUser ApplicationUser { get; set; } = null!;

    public Guid LanguageId { get; set; }

    public Language Language { get; set; } = null!;

    public int Rating { get; set; }

    public int MaxRating { get; set; }

    public int TotalGames { get; set; }

    public int TotalWins { get; set; }
}
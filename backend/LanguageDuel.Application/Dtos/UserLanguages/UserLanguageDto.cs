namespace LanguageDuel.Application.Dtos.UserLanguages;

public class UserLanguageDto
{
    public Guid LanguageId { get; set; }

    public int Rating { get; set; }

    public int MaxRating { get; set; }

    public int TotalGames { get; set; }

    public int TotalWins { get; set; }
}
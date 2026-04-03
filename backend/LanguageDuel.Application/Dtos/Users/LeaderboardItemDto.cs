namespace LanguageDuel.Application.Dtos.Users;

public class LeaderboardItemDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Language { get; set; } = string.Empty;
    public string? ImageUrl { get; set; }
    public int TotalWins { get; set; }
    public int TotalGames { get; set; }
    public int Rank { get; set; }
}
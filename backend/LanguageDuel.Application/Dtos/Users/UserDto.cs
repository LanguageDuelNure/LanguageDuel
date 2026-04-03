using LanguageDuel.Application.Dtos.UserLanguages;

namespace LanguageDuel.Application.Dtos.Users;

public class UserDto
{
    public Guid Id { get; set; }

    public string Name { get; set; } = string.Empty;

    public List<UserLanguageDto> LanguageRatings { get; set; }

    public int TotalGames { get; set; }

    public int TotalWins { get; set; }

    public List<UserOpponentDto> UserOpponents { get; set; }
    
    public string? ImageUrl { get; set; }
}
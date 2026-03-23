using LanguageDuel.Application.Dtos.Questions;

namespace LanguageDuel.Application.Dtos.Games;

public class GameStateDto
{
    public GameStateQuestionDto? CurrentQuestion { get; set; } = null!;
    
    public List<GameSessionUserDto> Users { get; set; } = [];
    
    public int? TimeRemainingInSeconds { get; set; }
    
    public Guid? CorrectAnswerId { get; set; }
    
    public string LanguageName { get; set; } = string.Empty;
}
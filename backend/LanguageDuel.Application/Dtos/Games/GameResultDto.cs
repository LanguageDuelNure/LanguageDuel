using LanguageDuel.Application.Dtos.Questions;

namespace LanguageDuel.Application.Dtos.Games;

public class GameResultDto
{
    public bool IsVictory { get; set; }
    
    public DateTime CreatedAt { get; set; }
    
    public string YourName { get; set; }
    
    public string OpponentName { get; set; }
    
    public Guid LanguageId { get; set; }
    
    public string LanguageName { get; set; }
    
    public Guid DifficultyLevelId { get; set; }
    
    public string DifficultyLevelName { get; set; }
    
    public IEnumerable<QuestionDto> Questions { get; set; }
}
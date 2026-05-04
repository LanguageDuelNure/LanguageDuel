namespace LanguageDuel.Application.Dtos.Games;

public class GameResultListItemDto
{
    public Guid Id { get; set; }
    
    public bool IsVictory { get; set; }
    
    public string YourName { get; set; }
    
    public string OpponentName { get; set; }
    
    public Guid LanguageId { get; set; }
    
    public string LanguageName { get; set; }
    
    public Guid DifficultyLevelId { get; set; }
    
    public string DifficultyLevelName { get; set; }
}
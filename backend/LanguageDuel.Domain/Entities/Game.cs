namespace LanguageDuel.Domain.Entities;

public class Game
{
    public Guid Id { get; set; }
    
    public DateTime CreatedAt { get; set; }
    
    public Guid LanguageId { get; set; }
    
    public Language Language { get; set; }
    
    public Guid DifficultyLevelId { get; set; }
    
    public DifficultyLevel DifficultyLevel { get; set; }
    
    public ICollection<GameQuestion> GameQuestions { get; set; } = [];
    
    public ICollection<GameApplicationUser> GameApplicationUsers { get; set; } = [];
}
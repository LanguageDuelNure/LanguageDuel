namespace LanguageDuel.Domain.Entities;

public class DifficultyLevel
{
    public Guid Id { get; set; }
    
    public string Name { get; set; } = string.Empty;
    
    public int StartRating { get; set; }
    
    public ICollection<Question> Questions { get; set; } = [];
}
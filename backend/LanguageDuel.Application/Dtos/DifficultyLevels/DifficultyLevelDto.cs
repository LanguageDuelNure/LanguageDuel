namespace LanguageDuel.Application.Dtos.DifficultyLevels;

public class DifficultyLevelDto
{
    public Guid Id { get; set; }
    
    public string Name { get; set; } = string.Empty;
    
    public int StartRating { get; set; }
}
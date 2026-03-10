namespace LanguageDuel.Domain;

public class Answer
{
    public Guid Id { get; set; }
    
    public string Name { get; set; } = string.Empty;
    
    public Question Question { get; set; } = null!;
    
    public Guid QuestionId { get; set; }
    
    public bool IsCorrect { get; set; }
}
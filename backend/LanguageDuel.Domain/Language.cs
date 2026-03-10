namespace LanguageDuel.Domain;

public class Language
{
    public Guid Id { get; set; }
    
    public string Name { get; set; } = string.Empty;
    
    public ICollection<Question> Questions { get; set; } = [];
}
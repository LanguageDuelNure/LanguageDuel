namespace LanguageDuel.Application.Dtos.Languages;

public class LanguageDto
{
    public Guid Id { get; set; }
    
    public string Name { get; set; } = string.Empty;
    
    public int Rating { get; set; }
}
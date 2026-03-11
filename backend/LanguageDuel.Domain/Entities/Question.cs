using System.Text.Json.Serialization;
using LanguageDuel.Domain.Entities;

namespace LanguageDuel.Domain;

public class Question
{
    public Guid Id { get; set; }
    
    public string Name { get; set; } = string.Empty;
    [JsonIgnore]
    public Language Language { get; set; } = null!;
    
    public Guid LanguageId { get; set; }
    [JsonIgnore]
    public DifficultyLevel DifficultyLevel { get; set; } = null!;
    
    public Guid DifficultyLevelId { get; set; }
    
    public ICollection<Answer> Answers { get; set; } = new List<Answer>();
}
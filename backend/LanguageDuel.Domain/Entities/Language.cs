namespace LanguageDuel.Domain.Entities;

public class Language
{
    public Guid Id { get; set; }

    public string Name { get; set; } = string.Empty;

    public ICollection<Question> Questions { get; set; } = [];

    public ICollection<ApplicationUserLanguage> ApplicationUserLanguages { get; set; } = [];
}
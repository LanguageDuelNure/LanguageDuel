using LanguageDuel.Domain.Entities;

namespace LanguageDuel.Domain;

public class ApplicationUserLanguage
{
    public Guid ApplicationUserId { get; set; }

    public ApplicationUser ApplicationUser { get; set; } = null!;
    
    public Guid LanguageId { get; set; }
    
    public Language Language { get; set; } = null!;
    
    public int Rating { get; set; }
}
using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Identity;

namespace LanguageDuel.Domain.Entities;

public class ApplicationUser : IdentityUser<Guid>
{
    [MaxLength(6)]
    public string VerificationCode { get; set; } = string.Empty;

    [MaxLength(50)]
    public string Name { get; set; } = string.Empty;
    
    public ICollection<ApplicationUserLanguage> ApplicationUserLanguages { get; set; } = [];
}
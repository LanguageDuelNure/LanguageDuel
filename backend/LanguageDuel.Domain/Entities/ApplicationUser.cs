using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Identity;

namespace LanguageDuel.Domain.Entities;

public class ApplicationUser : IdentityUser<Guid>
{
    [MaxLength(6)]
    public string VerificationCode { get; set; } = string.Empty;
    
    [MaxLength(1000)]
    public string BanReason { get; set; } = string.Empty;

    [MaxLength(50)]
    public string Name { get; set; } = string.Empty;

    public int TotalGames { get; set; }

    public int TotalWins { get; set; }

    public ICollection<ApplicationUserLanguage> ApplicationUserLanguages { get; set; } = [];

    public ICollection<ApplicationUserOpponent> ApplicationUserOpponents { get; set; } = [];

    public ICollection<ApplicationUserOpponent> OpponentApplicationUsers { get; set; } = [];
}
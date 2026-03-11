using LanguageDuel.Domain;
using LanguageDuel.Domain.Entities;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace LanguageDuel.Infrastructure;

public class ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : IdentityDbContext<ApplicationUser, IdentityRole<Guid>, Guid>(options)
{
    public DbSet<Question> Questions { get; set; }
    
    public DbSet<Answer> Answers { get; set; }
    
    public DbSet<DifficultyLevel> DifficultyLevels { get; set; }
    
    public DbSet<Language> Languages { get; set; }
    
    public DbSet<ApplicationUserLanguage> ApplicationUserLanguages { get; set; }
    
    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        builder.Entity<ApplicationUserLanguage>()
            .HasOne(aul => aul.ApplicationUser)
            .WithMany(au => au.ApplicationUserLanguages)
            .HasForeignKey(aul => aul.ApplicationUserId);
        
        builder.Entity<ApplicationUserLanguage>()
            .HasOne(aul => aul.Language)
            .WithMany(l => l.ApplicationUserLanguages)
            .HasForeignKey(aul => aul.LanguageId);
        
        builder.Entity<ApplicationUserLanguage>()
            .HasKey(aul => new { aul.ApplicationUserId, aul.LanguageId });
    }
}

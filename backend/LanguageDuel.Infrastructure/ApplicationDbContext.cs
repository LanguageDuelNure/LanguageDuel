using LanguageDuel.Domain.Entities;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;

namespace LanguageDuel.Infrastructure;

public class ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : IdentityDbContext<ApplicationUser, IdentityRole<Guid>, Guid>(options)
{
    public DbSet<Question> Questions { get; set; }

    public DbSet<Answer> Answers { get; set; }

    public DbSet<DifficultyLevel> DifficultyLevels { get; set; }

    public DbSet<Language> Languages { get; set; }

    public DbSet<ApplicationUserLanguage> ApplicationUserLanguages { get; set; }

    public DbSet<ApplicationUserOpponent> ApplicationUserOpponents { get; set; }
    
    public DbSet<Ticket> Tickets { get; set; }
    
    public DbSet<TicketMessage> TicketMessages { get; set; }
    
    public DbSet<Game> Games { get; set; }
    
    public DbSet<GameApplicationUser> GameApplicationUsers { get; set; }
    
    public DbSet<GameQuestion> GameQuestions { get; set; }
    
    public DbSet<GameAnswer> GameAnswers { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        base.OnConfiguring(optionsBuilder);

        optionsBuilder.ConfigureWarnings(w =>
            w.Ignore(CoreEventId.NavigationBaseIncludeIgnored));
    }

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        builder.Entity<ApplicationUserLanguage>()
            .HasKey(aul => new { aul.ApplicationUserId, aul.LanguageId });

        builder.Entity<ApplicationUserOpponent>()
            .HasOne(aul => aul.ApplicationUser)
            .WithMany(l => l.ApplicationUserOpponents)
            .HasForeignKey(aul => aul.ApplicationUserId);

        builder.Entity<ApplicationUserOpponent>()
            .HasOne(aul => aul.Opponent)
            .WithMany(l => l.OpponentApplicationUsers)
            .HasForeignKey(aul => aul.OpponentId);

        builder.Entity<ApplicationUserOpponent>()
            .HasKey(auo => new { auo.ApplicationUserId, auo.OpponentId });
        
        builder.Entity<GameApplicationUser>()
            .HasKey(auo => new { auo.GameId, auo.ApplicationUserId });
        
        builder.Entity<GameAnswer>()
            .HasKey(auo => new { auo.GameQuestionId, auo.AnswerId });
    }
}

using System.Reflection;
using System.Text.Json;
using LanguageDuel.Domain.Common;
using LanguageDuel.Domain.Entities;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace LanguageDuel.Infrastructure;

public static class DbInitializer
{
    private const string DefaultPassword = "77228Glnik!";
    
    private static readonly PasswordHasher<ApplicationUser> PasswordHasher = new();

    public static async Task InitializeAsync(ApplicationDbContext context)
    {
        await InitializeDefaultRolesAsync(context);
        await InitializeDefaultLanguagesAsync(context);
        await InitializeDefaultDifficultyLevelAsync(context);
        await InitializeDefaultQuestionsAsync(context);
        await InitializeDefaultUsersAsync(context);
    }

    private static async Task InitializeDefaultRolesAsync(ApplicationDbContext context)
    {
        if (await context.Roles.AnyAsync())
        {
            return;
        }

        await context.Roles.AddAsync(DefaultRoles.UserRole);
        await context.Roles.AddAsync(DefaultRoles.AdminRole);
        await context.SaveChangesAsync();
    }

    private static async Task InitializeDefaultLanguagesAsync(ApplicationDbContext context)
    {
        if (await context.Languages.AnyAsync())
        {
            return;
        }

        await context.Languages.AddAsync(DefaultLanguages.EnglishLanguage);
        await context.Languages.AddAsync(DefaultLanguages.SpanishLanguage);
        await context.SaveChangesAsync();
    }

    private static async Task InitializeDefaultDifficultyLevelAsync(ApplicationDbContext context)
    {
        if (await context.DifficultyLevels.AnyAsync())
        {
            return;
        }

        await context.DifficultyLevels.AddAsync(DefaultDifficultyLevels.EasyDifficulty);
        await context.DifficultyLevels.AddAsync(DefaultDifficultyLevels.MediumDifficulty);
        await context.DifficultyLevels.AddAsync(DefaultDifficultyLevels.HardDifficulty);
        await context.DifficultyLevels.AddAsync(DefaultDifficultyLevels.VeryHardDifficulty);
        await context.SaveChangesAsync();
    }

    private static async Task InitializeDefaultQuestionsAsync(ApplicationDbContext context)
    {
        if (await context.Questions.AnyAsync())
        {
            return;
        }

        const string resourceTemplate = "LanguageDuel.Infrastructure.InitialData.{}-questions.json";
        
        await ImportQuestionsAsync(context, resourceTemplate.Replace("{}", "english"), DefaultLanguages.EnglishLanguage.Id);
        await ImportQuestionsAsync(context, resourceTemplate.Replace("{}", "spanish"), DefaultLanguages.SpanishLanguage.Id);
    }

    private static async Task ImportQuestionsAsync(ApplicationDbContext context, string resourceName, Guid languageId)
    {
        var json = await GetResourceAsync(resourceName);
        var questions = JsonSerializer.Deserialize<Question[]>(json);

        if (questions != null)
        {
            foreach (var question in questions)
            {
                question.LanguageId = languageId;
                context.Questions.Add(question);
            }

            await context.SaveChangesAsync();
        }
    }

    private static async Task InitializeDefaultUsersAsync(ApplicationDbContext context)
    {
        foreach (var user in DefaultUsers.Users)
        {
            if (!await context.Users.AnyAsync(u => u.Email == user.Email))
            {
                user.PasswordHash = PasswordHasher.HashPassword(user, DefaultPassword);
                
                await context.Users.AddAsync(user);
                
                await context.UserRoles.AddAsync(new IdentityUserRole<Guid>
                {
                    UserId = user.Id,
                    RoleId = DefaultRoles.UserRole.Id
                });
            }
        }
        
        foreach (var admin in DefaultUsers.AdminUsers)
        {
            if (!await context.Users.AnyAsync(u => u.Email == admin.Email))
            {
                admin.PasswordHash = PasswordHasher.HashPassword(admin, DefaultPassword);
                
                await context.Users.AddAsync(admin);
                
                await context.UserRoles.AddAsync(new IdentityUserRole<Guid>
                {
                    UserId = admin.Id,
                    RoleId = DefaultRoles.AdminRole.Id
                });
            }
        }

        await context.SaveChangesAsync();
    }

    private static async Task<string> GetResourceAsync(string resourceName)
    {
        var assembly = Assembly.GetExecutingAssembly();
        await using Stream stream = assembly.GetManifestResourceStream(resourceName)!;
        using StreamReader reader = new(stream);
        return await reader.ReadToEndAsync();
    }
}
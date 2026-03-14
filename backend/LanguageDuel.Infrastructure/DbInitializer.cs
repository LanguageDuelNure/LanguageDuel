using System.Reflection;
using System.Text.Json;
using LanguageDuel.Domain;
using LanguageDuel.Domain.Entities;
using LanguageDuel.Infrastructure.Common;
using Microsoft.EntityFrameworkCore;

namespace LanguageDuel.Infrastructure;

public static class DbInitializer
{
    public static async Task InitializeAsync(ApplicationDbContext context)
    {
        await InitializeDefaultRolesAsync(context);
        await InitializeDefaultLanguagesAsync(context);
        await InitializeDefaultDifficultyLevelAsync(context);
        await InitializeDefaultQuestionsAsync(context);
    }

    private static async Task InitializeDefaultRolesAsync(ApplicationDbContext context)
    {
        if (await context.Roles.AnyAsync()) return;

        await context.Roles.AddAsync(DefaultRoles.UserRole);
        await context.Roles.AddAsync(DefaultRoles.AdminRole);
    }
    
    private static async Task InitializeDefaultLanguagesAsync(ApplicationDbContext context)
    {
        if (await context.Languages.AnyAsync()) return;

        await context.Languages.AddAsync(DefaultLanguages.EnglishLanguage);
        await context.Languages.AddAsync(DefaultLanguages.SpanishLanguage);
    }
    
    private static async Task InitializeDefaultDifficultyLevelAsync(ApplicationDbContext context)
    {
        if (await context.Roles.AnyAsync()) return;

        await context.DifficultyLevels.AddAsync(DefaultDifficultyLevels.EasyDifficulty);
        await context.DifficultyLevels.AddAsync(DefaultDifficultyLevels.MediumDifficulty);
        await context.DifficultyLevels.AddAsync(DefaultDifficultyLevels.HardDifficulty);
        await context.DifficultyLevels.AddAsync(DefaultDifficultyLevels.VeryHardDifficulty);
    }

    private static async Task InitializeDefaultQuestionsAsync(ApplicationDbContext context)
    {
        const string resourceTemplate = "LanguageDuel.Infrastructure.InitialData.{}-questions.json";
        var englishQuestionsResource = resourceTemplate.Replace("{}", "english");
        var spanishQuestionsResource = resourceTemplate.Replace("{}", "spanish");

        var englishQuestionsJson = await GetResourceAsync(englishQuestionsResource);
        var englishQuestions = JsonSerializer.Deserialize<Question[]>(englishQuestionsJson);
        
        if (englishQuestions != null)
        {
            foreach (var englishQuestion in englishQuestions)
            {
                englishQuestion.LanguageId = DefaultLanguages.EnglishLanguage.Id;
                if (!await context.Questions.AnyAsync(q => q.Name == englishQuestion.Name))
                {
                    context.Questions.Add(englishQuestion);
                }
            }
            
            await context.SaveChangesAsync();
        }
        
        var spanishQuestionsJson = await GetResourceAsync(spanishQuestionsResource);
        var spanishQuestions = JsonSerializer.Deserialize<Question[]>(spanishQuestionsJson);
        
        if (spanishQuestions != null)
        {
            foreach (var spanishQuestion in spanishQuestions)
            {
                spanishQuestion.LanguageId = DefaultLanguages.SpanishLanguage.Id;
                if (!await context.Questions.AnyAsync(q => q.Name == spanishQuestion.Name))
                {
                    context.Questions.Add(spanishQuestion);
                }
            }

            await context.SaveChangesAsync();
        }
    }

    private static async Task<string> GetResourceAsync(string resourceName)
    {
        var assembly = Assembly.GetExecutingAssembly();
        await using Stream stream = assembly.GetManifestResourceStream(resourceName)!;
        using StreamReader reader = new StreamReader(stream);
        return await reader.ReadToEndAsync();
    }
}

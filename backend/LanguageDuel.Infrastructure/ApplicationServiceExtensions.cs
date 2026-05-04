using LanguageDuel.Application.Services;
using LanguageDuel.Application.Services.ApplicationUserLanguages;
using LanguageDuel.Application.Services.ApplicationUserOpponents;
using LanguageDuel.Application.Services.DifficultyLevels;
using LanguageDuel.Application.Services.Games;
using LanguageDuel.Application.Services.Languages;
using LanguageDuel.Application.Services.Questions;
using LanguageDuel.Application.Services.Tickets;
using LanguageDuel.Infrastructure.Services;
using Microsoft.Extensions.DependencyInjection;
namespace LanguageDuel.Infrastructure;

public static class ApplicationServiceExtensions
{
    public static IServiceCollection AddApplicationServices(this IServiceCollection services)
    {
        services.AddScoped<IUserService, UserService>();
        services.AddSingleton<IGameService, GameService>();
        services.AddScoped<ILanguageService, LanguageService>();
        services.AddScoped<IQuestionService, QuestionService>();
        services.AddScoped<IDifficultyLevelService, DifficultyLevelService>();
        services.AddScoped<IApplicationUserLanguageService, ApplicationUserLanguageService>();
        services.AddScoped<IApplicationUserOpponentService, ApplicationUserOpponentService>();
        services.AddScoped<ITicketService, TicketService>();

        services.AddSingleton<INotificationService, NotificationService>();

        return services;
    }
}

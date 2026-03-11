using LanguageDuel.Application.Services;
using LanguageDuel.Application.Services.Games;
using LanguageDuel.Application.Services.Languages;
using LanguageDuel.Application.Services.Questions;
using LanguageDuel.Infrastructure.Services;
using Microsoft.Extensions.DependencyInjection;
namespace LanguageDuel.Infrastructure;

public static class ApplicationServiceExtensions
{
    public static IServiceCollection AddApplicationServices(this IServiceCollection services)
    {
        services.AddScoped<IUserService, UserService>();
        services.AddScoped<IGameService, GameService>();
        services.AddScoped<ILanguageService, LanguageService>();
        services.AddScoped<IQuestionService, QuestionService>();
        
        services.AddScoped<INotificationService, NotificationService>();

        return services;
    }
}

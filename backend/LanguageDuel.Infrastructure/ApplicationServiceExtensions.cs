using LanguageDuel.Application.Services;
using LanguageDuel.Infrastructure.Services;
using Microsoft.Extensions.DependencyInjection;
namespace LanguageDuel.Infrastructure;

public static class ApplicationServiceExtensions
{
    public static IServiceCollection AddApplicationServices(this IServiceCollection services)
    {
        services.AddScoped<IUserService, UserService>();

        return services;
    }
}

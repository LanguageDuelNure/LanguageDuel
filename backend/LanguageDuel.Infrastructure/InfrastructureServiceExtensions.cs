using LanguageDuel.Application.Repositories;
using LanguageDuel.Application.Services;
using LanguageDuel.Domain;
using LanguageDuel.Infrastructure.Options;
using LanguageDuel.Infrastructure.Repositories;
using LanguageDuel.Infrastructure.Services;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.UI.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
namespace LanguageDuel.Infrastructure;

public static class InfrastructureServiceExtensions
{
    public static IServiceCollection AddInfrastructureServices(this IServiceCollection services, IConfigurationManager configuration)
    {
        var connectionString = configuration.GetConnectionString("LinuxConnection") ?? throw new InvalidOperationException("Connection string 'LinuxConnection' not found.");
        
        services.AddDbContext<ApplicationDbContext>(options =>
            options.UseMySql(connectionString, ServerVersion.AutoDetect(connectionString)));

        services.AddDefaultIdentity<ApplicationUser>(options =>
        {
            options.SignIn.RequireConfirmedAccount = true;
            options.Password = new PasswordOptions
            {
                RequireNonAlphanumeric = false
            };
        })
            .AddRoles<IdentityRole>()
            .AddEntityFrameworkStores<ApplicationDbContext>();
        
        services.AddSignalR();

        services.AddScoped<IEmailSender, SmtpEmailSender>();
        services.AddScoped<IJwtTokenService, JwtTokenService>();

        services.AddScoped<IUnitOfWork, UnitOfWork>();

        services.Configure<SmtpEmailOptions>(configuration.GetSection("EmailOptions"));
        services.Configure<JwtTokenOptions>(configuration.GetSection("Jwt"));

        return services;
    }
}

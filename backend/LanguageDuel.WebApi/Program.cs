using System.Reflection;
using System.Text;
using LanguageDuel.Application.Options;
using LanguageDuel.Infrastructure;
using LanguageDuel.Infrastructure.Hubs;
using LanguageDuel.WebApi;
using LanguageDuel.WebApi.Middlewares;
using LanguageDuel.WebApi.ServiceExtensions;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;

WebApplicationBuilder builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

builder.Services
    .AddInfrastructureServices(builder.Configuration)
    .AddApplicationServices()
    .AddSwaggerOpenApi();

builder.Services.AddAutoMapper(_ => { }, AppDomain.CurrentDomain.GetAssemblies());

builder.Services.Configure<GameLogicOptions>(builder.Configuration.GetSection("GameLogic"));

var token = builder.Configuration.GetSection("Jwt:Key").Value ?? throw new InvalidOperationException("Jwt key not found");
var issuer = builder.Configuration.GetSection("Jwt:Issuer").Value ?? throw new InvalidOperationException("Jwt key not found");
var audience = builder.Configuration.GetSection("Jwt:Audience").Value ?? throw new InvalidOperationException("Jwt key not found");

builder.Services
    .AddCors(options =>
    {
        options.AddPolicy("Access-Control-Allow-Origin", policy =>
        {
            policy.AllowAnyOrigin()
                .AllowAnyMethod()
                .AllowAnyHeader();
        });
    })
    .AddAuthentication(opt =>
    {
        opt.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
        opt.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
    })
    .AddJwtBearer(opt =>
    {
        opt.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(token)),
            ValidIssuer = issuer,
            ValidAudience = audience
        };
    });

builder.Services.ConfigureApiBehaviourOptions();

WebApplication app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    _ = app.UseSwagger();
    _ = app.UseSwaggerUI();
}

using var scope = app.Services.CreateScope();
var dbContext = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
dbContext.Database.EnsureCreated();

await DbInitializer.InitializeAsync(dbContext);

app.UseCors("Access-Control-Allow-Origin");

app.UseMiddleware<UserBannedMiddleware>();

app.UseDefaultFiles();
app.UseStaticFiles();

app.UseAuthorization();

app.MapHub<GameHub>("/gameHub");

app.MapControllers();

app.Run();

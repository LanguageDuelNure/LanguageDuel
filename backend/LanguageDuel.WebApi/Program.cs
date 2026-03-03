using System.Text;
using LanguageDuel.Infrastructure;
using LanguageDuel.WebApi;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;

WebApplicationBuilder builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddAutoMapper(p => { }, AppDomain.CurrentDomain.GetAssemblies());

builder.Services
    .AddInfrastructureServices(builder.Configuration)
    .AddApplicationServices();

var token = builder.Configuration.GetSection("Jwt:Key").Value ?? throw new InvalidOperationException("Jwt key not found");
var issuer = builder.Configuration.GetSection("Jwt:Issuer").Value ?? throw new InvalidOperationException("Jwt key not found");
var audience = builder.Configuration.GetSection("Jwt:Audience").Value ?? throw new InvalidOperationException("Jwt key not found");

builder.Services
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

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();

using System.Security.Claims;
using LanguageDuel.Application.Dtos.Results;
using LanguageDuel.Application.Services;

namespace LanguageDuel.WebApi.Middlewares;

public class UserBannedMiddleware
{
    private readonly RequestDelegate _next;

    public UserBannedMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext context, IUserService userService)
    {
        if (context.User.Identity?.IsAuthenticated == true)
        {
            var userId = context.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (!string.IsNullOrEmpty(userId))
            {
                var isUserBannedResult = await userService.IsUserBannedAsync(userId);
                if (isUserBannedResult.IsSuccess)
                {
                    await _next(context);
                    return;
                }
                context.Response.StatusCode = StatusCodes.Status403Forbidden;
                await context.Response.WriteAsJsonAsync(isUserBannedResult);
                return;
            }
        }

        await _next(context);
    }
}
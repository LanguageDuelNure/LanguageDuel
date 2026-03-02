using System.Text.Json;
using LanguageDuel.Application.Dtos.Results;

namespace LanguageDuel.WebApi;

public class GlobalExceptionHandler(RequestDelegate next, ILogger<GlobalExceptionHandler> logger)
{
    private const string _errorMessage = "An unexpected error occurred.";
    private readonly RequestDelegate _next = next;
    private readonly ILogger<GlobalExceptionHandler> _logger = logger;

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, _errorMessage);

            context.Response.StatusCode = 500;
            context.Response.ContentType = "application/json";

            var errorResponse = new Result
            {
                Errors =
                [
                    new()
                    {
                        Key = ErrorKey.UnexpectedError,
                        Message = _errorMessage,
                    },
                ],
            };

            var jsonResponse = JsonSerializer.Serialize(errorResponse);
            await context.Response.WriteAsync(jsonResponse);
        }
    }
}

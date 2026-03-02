using System.Text.Json;
using LanguageDuel.Application.Dtos.Results;
using Microsoft.AspNetCore.Mvc;

namespace LanguageDuel.WebApi;

public static class ApiBehaviorOptionsConfiguration
{
    public static IServiceCollection ConfigureApiBehaviourOptions(this IServiceCollection services)
    {
        services.Configure<ApiBehaviorOptions>(options =>
        {
            options.InvalidModelStateResponseFactory = context =>
            {
                var errors = context.ModelState
                    .Where(entry => entry.Value != null && entry.Value.Errors.Count > 0)
                    .SelectMany(entry =>
                        entry.Value!.Errors
                            .Select(er =>
                            {
                                try
                                {
                                    return JsonSerializer.Deserialize<Error>(er.ErrorMessage);
                                }
                                catch
                                {
                                    return new Error
                                    {
                                        Key = ErrorKey.Required,
                                        Message = er.ErrorMessage,
                                    };
                                }
                            }))
                    .ToList();
                var result = new Result
                {
                    Errors = errors!,
                };
                return new BadRequestObjectResult(result);
            };
        });
        return services;
    }
}

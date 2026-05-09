using LanguageDuel.Application.Dtos.Languages;
using LanguageDuel.Application.Dtos.Results;
using LanguageDuel.Application.Services.Languages;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace LanguageDuel.WebApi.Controllers;

[Route("api/[controller]")]
[ApiController]
public class LanguagesController(ILanguageService languageService) : BaseController
{
    /// <summary>
    /// Retrieves a list of available languages.
    /// </summary>
    /// <remarks>
    /// Provides a list of languages supported by the application along with user-specific statistics or settings if available.
    /// </remarks>
    [HttpGet]
    [Authorize]
    [ProducesResponseType(typeof(IEnumerable<LanguageDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<LanguageDto>> GetLanguages()
    {
        var result = await languageService.GetLanguagesAsync(GetUserId());
        if (!result.IsSuccess)
        {
            return HandleErrors(result);
        }

        var languages = result.Value;

        return Ok(languages);
    }
}
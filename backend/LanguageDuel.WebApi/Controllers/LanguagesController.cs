using LanguageDuel.Application.Dtos.Languages;
using LanguageDuel.Application.Dtos.Results;
using LanguageDuel.Application.Dtos.Users;
using LanguageDuel.Application.Services.Languages;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace LanguageDuel.WebApi.Controllers;

[Route("api/[controller]")]
[ApiController]
public class LanguagesController(ILanguageService languageService) : BaseController
{
    /// <remarks>
    /// Error keys:
    /// - UNEXPECTED_ERROR
    /// </remarks>
    [HttpGet]
    [Authorize]
    [ProducesResponseType(typeof(IEnumerable<LanguageDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status500InternalServerError)]
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
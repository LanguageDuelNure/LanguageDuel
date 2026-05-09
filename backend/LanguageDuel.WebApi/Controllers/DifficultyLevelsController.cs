using LanguageDuel.Application.Dtos.DifficultyLevels;
using LanguageDuel.Application.Services.DifficultyLevels;
using Microsoft.AspNetCore.Mvc;

namespace LanguageDuel.WebApi.Controllers;

[Route("api/[controller]")]
[ApiController]
public class DifficultyLevelsController(IDifficultyLevelService difficultyLevelService) : BaseController
{
    /// <summary>
    /// Retrieves a list of all available game difficulty levels.
    /// </summary>
    /// <remarks>
    /// Provides information about difficulty tiers, including their rating requirements and configuration.
    /// </remarks>
    [HttpGet]
    [ProducesResponseType(typeof(IEnumerable<DifficultyLevelDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<DifficultyLevelDto>> GetDifficultyLevels()
    {
        var result = await difficultyLevelService.GetDifficultyLevelsAsync();
        return !result.IsSuccess ? HandleErrors(result) : Ok(result.Value);
    }
}
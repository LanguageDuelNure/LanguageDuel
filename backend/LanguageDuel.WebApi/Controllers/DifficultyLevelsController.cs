using LanguageDuel.Application.Dtos.DifficultyLevels;
using LanguageDuel.Application.Services.DifficultyLevels;
using Microsoft.AspNetCore.Mvc;

namespace LanguageDuel.WebApi.Controllers;

[Route("api/[controller]")]
[ApiController]
public class DifficultyLevelsController(IDifficultyLevelService difficultyLevelService) : BaseController
{
    [HttpGet]
    public async Task<ActionResult<DifficultyLevelDto>> GetDifficultyLevels()
    {
        var result = await difficultyLevelService.GetDifficultyLevelsAsync();
        return !result.IsSuccess ? HandleErrors(result) : Ok(result.Value);
    }
}
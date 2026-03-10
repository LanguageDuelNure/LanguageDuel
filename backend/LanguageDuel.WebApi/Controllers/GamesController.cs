using LanguageDuel.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;

namespace LanguageDuel.WebApi.Controllers;

[Route("api/[controller]")]
[ApiController]
public class GamesController(IGameService gameService) : BaseController
{
    [HttpPost]
    [Authorize]
    public async Task<ActionResult> SendGameInvitation()
    {
        var result = await gameService.SendGameInvitationsAsync(GetUserId());
        return !result.IsSuccess ? HandleErrors(result) : NoContent();
    }
}
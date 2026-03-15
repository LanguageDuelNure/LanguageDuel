using LanguageDuel.Application.Services;
using LanguageDuel.Application.Services.Games;
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
    public async Task<ActionResult> SendGameInvitation(Guid languageId)
    {
        var result = await gameService.SendGameInvitationsAsync(GetUserId(), languageId);
        return !result.IsSuccess ? HandleErrors(result) : NoContent();
    }
    
    [HttpDelete]
    [Authorize]
    public async Task<ActionResult> RemoveFromSearchGroupsAsync(Guid languageId)
    {
        var result = await gameService.RemoveFromSearchGroupsAsync(GetUserId(), languageId);
        return !result.IsSuccess ? HandleErrors(result) : NoContent();
    }
    
    [HttpPost("answer")]
    [Authorize]
    public async Task<ActionResult> ChooseAnswer(Guid gameId, Guid answerId)
    {
        var result = await gameService.ChooseAnswerAsync(GetUserId(), gameId, answerId);
        return !result.IsSuccess ? HandleErrors(result) : NoContent();
    }
}
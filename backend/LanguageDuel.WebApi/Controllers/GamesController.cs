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
    /// <remarks>
    /// Error keys:
    /// - UNEXPECTED_ERROR
    /// </remarks>
    [HttpGet("current")]
    [Authorize]
    public ActionResult GetGame()
    {
        var result = gameService.GetGame(GetUserId());
        return !result.IsSuccess ? HandleErrors(result) : Ok(result.Value);
    }
    
    /// <remarks>
    /// Error keys:
    /// - UNEXPECTED_ERROR
    /// </remarks>
    [HttpGet("state")]
    [Authorize]
    public async Task<ActionResult> SendGameStateAsync(Guid gameId)
    {
        var result = await gameService.SendGameStateAsync(gameId);
        return !result.IsSuccess ? HandleErrors(result) : NoContent();
    }
    
    /// <remarks>
    /// Error keys:
    /// - UNEXPECTED_ERROR
    /// </remarks>
    [HttpPost]
    [Authorize]
    public async Task<ActionResult> SendGameInvitation(Guid languageId)
    {
        var result = await gameService.SendGameInvitationsAsync(GetUserId(), languageId);
        return !result.IsSuccess ? HandleErrors(result) : NoContent();
    }
    
    /// <remarks>
    /// Error keys:
    /// - UNEXPECTED_ERROR
    /// </remarks>
    [HttpDelete]
    [Authorize]
    public async Task<ActionResult> RemoveFromSearchGroupsAsync(Guid languageId)
    {
        var result = await gameService.RemoveFromSearchGroupsAsync(GetUserId(), languageId);
        return !result.IsSuccess ? HandleErrors(result) : NoContent();
    }
    
    /// <remarks>
    /// Error keys:
    /// - ALREADY_CHOSEN (if opponent has already chosen this answer, and it is incorrect)
    /// - ALREADY_EXISTS (if you have already chosen answer for this question)
    /// - UNEXPECTED_ERROR
    /// </remarks>
    [HttpPost("answer")]
    [Authorize]
    public async Task<ActionResult> ChooseAnswer(Guid gameId, Guid answerId)
    {
        var result = await gameService.ChooseAnswerAsync(GetUserId(), gameId, answerId);
        return !result.IsSuccess ? HandleErrors(result) : NoContent();
    }
    
    /// <remarks>
    /// Error keys:
    /// - NOT_FOUND (game not found)
    /// - FORBIDDEN (give up in game where you are not participate)
    /// - UNEXPECTED_ERROR
    /// </remarks>
    [HttpPost("give-up")]
    [Authorize]
    public async Task<ActionResult> GiveUp(Guid gameId)
    {
        var result = await gameService.GiveUpAsync(GetUserId(), gameId);
        return !result.IsSuccess ? HandleErrors(result) : NoContent();
    }
}
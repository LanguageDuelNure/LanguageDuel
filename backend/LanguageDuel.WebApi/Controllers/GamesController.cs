using LanguageDuel.Application.Dtos.Games;
using LanguageDuel.Application.Dtos.Results;
using LanguageDuel.Application.Services.Games;
using Microsoft.AspNetCore.Authorization;
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
    [ProducesResponseType(typeof(Guid), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status404NotFound)]
    public ActionResult GetGame()
    {
        var result = gameService.GetGame(GetUserId());
        return !result.IsSuccess ? HandleErrors(result) : Ok(result.Value);
    }
    
    /// <remarks>
    /// Error keys:
    /// - UNEXPECTED_ERROR
    /// </remarks>
    [HttpGet("{gameId}/history")]
    [Authorize]
    [ProducesResponseType(typeof(GameResultDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status404NotFound)]
    public async Task<ActionResult<GameResultDto>> GetGameHistory(Guid gameId)
    {
        var result = await gameService.GetGameHistory(GetUserId(), gameId);
        return !result.IsSuccess ? HandleErrors(result) : Ok(result.Value);
    }
    
    /// <remarks>
    /// Error keys:
    /// - UNEXPECTED_ERROR
    /// </remarks>
    [HttpGet("history")]
    [Authorize]
    [ProducesResponseType(typeof(IEnumerable<GameResultListItemDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<GameResultListItemDto>>> GetGamesHistory()
    {
        var result = await gameService.GetGamesHistory(GetUserId());
        return !result.IsSuccess ? HandleErrors(result) : Ok(result.Value);
    }

    /// <remarks>
    /// Error keys:
    /// - UNEXPECTED_ERROR
    /// </remarks>
    [HttpGet("state")]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status400BadRequest)]
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
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status400BadRequest)]
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
    [ProducesResponseType(StatusCodes.Status204NoContent)]
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
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status400BadRequest)]
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
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status403Forbidden)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status404NotFound)]
    public async Task<ActionResult> GiveUp(Guid gameId)
    {
        var result = await gameService.GiveUpAsync(GetUserId(), gameId);
        return !result.IsSuccess ? HandleErrors(result) : NoContent();
    }
}
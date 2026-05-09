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
    /// <summary>
    /// Retrieves the ID of the user's current active game for reconnection purposes.
    /// </summary>
    /// <remarks>
    /// Use this method when the client needs to restore a lost connection. 
    /// It returns the ID of the ongoing match, allowing the client to rejoin the correct SignalR group.
    /// </remarks>
    [HttpGet("current")]
    [Authorize]
    [ProducesResponseType(typeof(Guid), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(void), StatusCodes.Status404NotFound)]
    public ActionResult<Guid> GetGame()
    {
        var result = gameService.GetGame(GetUserId());
        return !result.IsSuccess ? HandleErrors(result) : Ok(result.Value);
    }
    
    /// <summary>
    /// Retrieves detailed information about a specific finished game.
    /// </summary>
    /// <remarks>
    /// Returns full history including questions, all participants' answers, and the final result.
    /// </remarks>
    [HttpGet("{gameId}/history")]
    [Authorize]
    [ProducesResponseType(typeof(GameResultDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(void), StatusCodes.Status404NotFound)]
    public async Task<ActionResult<GameResultDto>> GetGameHistory(Guid gameId)
    {
        var result = await gameService.GetGameHistory(GetUserId(), gameId);
        return !result.IsSuccess ? HandleErrors(result) : Ok(result.Value);
    }
    
    /// <summary>
    /// Retrieves a list of all games played by the authorized user.
    /// </summary>
    /// <remarks>
    /// Returns a simplified list of game results for history display.
    /// </remarks>
    [HttpGet("history")]
    [Authorize]
    [ProducesResponseType(typeof(IEnumerable<GameResultListItemDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<GameResultListItemDto>>> GetGamesHistory()
    {
        var result = await gameService.GetGamesHistory(GetUserId());
        return !result.IsSuccess ? HandleErrors(result) : Ok(result.Value);
    }

    /// <summary>
    /// Requests an immediate synchronization of the game state via SignalR.
    /// </summary>
    /// <remarks>
    /// **Usage:** This method is intended solely for **reconnection purposes**. 
    /// After a client rejoins the game group following a connection loss, they should call this 
    /// to trigger an immediate 'GameStateChanged' event. This ensures the client displays 
    /// current data without waiting for the next automated server update.
    /// 
    /// **Important:** Do not use this method for regular state polling or updates. 
    /// During normal gameplay, the server automatically broadcasts state changes to all 
    /// participants.
    /// </remarks>
    [HttpGet("state")]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(void), StatusCodes.Status400BadRequest)]
    public async Task<ActionResult> SendGameStateAsync(Guid gameId)
    {
        var result = await gameService.SendGameStateAsync(gameId);
        return !result.IsSuccess ? HandleErrors(result) : NoContent();
    }

    /// <summary>
    /// Enters the matchmaking queue for a specific language.
    /// </summary>
    /// <remarks>
    /// The system will look for an opponent within the user's rating range and send a 'ReceiveGameInvitation' event.
    /// </remarks>
    [HttpPost]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(void), StatusCodes.Status400BadRequest)]
    public async Task<ActionResult> SendGameInvitation(Guid languageId)
    {
        var result = await gameService.SendGameInvitationsAsync(GetUserId(), languageId);
        return !result.IsSuccess ? HandleErrors(result) : NoContent();
    }

    /// <summary>
    /// Removes the user from the matchmaking queue for a specific language.
    /// </summary>
    [HttpDelete]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<ActionResult> RemoveFromSearchGroupsAsync(Guid languageId)
    {
        var result = await gameService.RemoveFromSearchGroupsAsync(GetUserId(), languageId);
        return !result.IsSuccess ? HandleErrors(result) : NoContent();
    }

    /// <summary>
    /// Submits an answer for the current question in an active game.
    /// </summary>
    /// <remarks>
    /// Error keys:
    /// - **ALREADY_CHOSEN**: Your opponent has already selected this incorrect answer.
    /// - **ALREADY_EXISTS**: You have already submitted an answer for this question.
    /// </remarks>
    [HttpPost("answer")]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(void), StatusCodes.Status400BadRequest)]
    public async Task<ActionResult> ChooseAnswer(Guid gameId, Guid answerId)
    {
        var result = await gameService.ChooseAnswerAsync(GetUserId(), gameId, answerId);
        return !result.IsSuccess ? HandleErrors(result) : NoContent();
    }

    /// <summary>
    /// Forfeits the current game session.
    /// </summary>
    /// <remarks>
    /// Error keys:
    /// - **NOT_FOUND**: The specified game session does not exist.
    /// - **FORBIDDEN**: You are not a participant in this game.
    /// </remarks>
    [HttpPost("give-up")]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(void), StatusCodes.Status403Forbidden)]
    [ProducesResponseType(typeof(void), StatusCodes.Status404NotFound)]
    public async Task<ActionResult> GiveUp(Guid gameId)
    {
        var result = await gameService.GiveUpAsync(GetUserId(), gameId);
        return !result.IsSuccess ? HandleErrors(result) : NoContent();
    }
}
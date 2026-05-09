using AutoMapper;
using LanguageDuel.Application.Dtos.Results;
using LanguageDuel.Application.Dtos.Tickets;
using LanguageDuel.Application.Dtos.Users;
using LanguageDuel.Application.Services.Tickets;
using LanguageDuel.WebApi.ActionAttributes;
using LanguageDuel.WebApi.Requests.Tickets;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace LanguageDuel.WebApi.Controllers;

[Route("api/[controller]")]
[ApiController]
public class TicketsController(ITicketService ticketService, IMapper mapper) : BaseController
{
    /// <summary>
    /// Creates a new support ticket.
    /// </summary>
    /// <remarks>
    /// Allows a user to submit a support request or report an issue.
    /// </remarks>
    [HttpPost]
    [Authorize]
    [AllowBanned]
    [ProducesResponseType(typeof(CreateTicketDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(void), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(void), StatusCodes.Status404NotFound)]
    public async Task<ActionResult<CreateTicketDto>> CreateTicket(CreateTicketRequestModel request)
    {
        var result = await ticketService.CreateTicketAsync(GetUserId(), mapper.Map<CreateTicketDto>(request));
        if (!result.IsSuccess) return HandleErrors(result);
        return Ok(result.Value);
    }

    /// <summary>
    /// Retrieves all tickets created by the authorized user.
    /// </summary>
    [HttpGet]
    [Authorize]
    [AllowBanned]
    [ProducesResponseType(typeof(IEnumerable<TicketListItemDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(void), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(void), StatusCodes.Status404NotFound)]
    public async Task<ActionResult<IEnumerable<TicketListItemDto>>> GetTicketsByUser()
    {
        var result = await ticketService.GetTicketsByUserAsync(GetUserId());
        if (!result.IsSuccess) return HandleErrors(result);
        return Ok(result.Value);
    }

    /// <summary>
    /// Retrieves all tickets with an 'Open' status.
    /// </summary>
    /// <remarks>
    /// Restricted to users with the Admin role.
    /// </remarks>
    [HttpGet("open")]
    [Authorize(Roles = "Admin")]
    [ProducesResponseType(typeof(IEnumerable<TicketListItemDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<TicketListItemDto>>> GetOpenTickets()
    {
        var result = await ticketService.GetOpenTicketsAsync();
        if (!result.IsSuccess) return HandleErrors(result);
        return Ok(result.Value);
    }

    /// <summary>
    /// Retrieves all tickets with an 'In Progress' status.
    /// </summary>
    /// <remarks>
    /// Restricted to users with the Admin role.
    /// </remarks>
    [HttpGet("in-progress")]
    [Authorize(Roles = "Admin")]
    [ProducesResponseType(typeof(IEnumerable<TicketListItemDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<TicketListItemDto>>> GetInProgressTickets()
    {
        var result = await ticketService.GetInProgressTicketsAsync();
        if (!result.IsSuccess) return HandleErrors(result);
        return Ok(result.Value);
    }

    /// <summary>
    /// Retrieves all closed support tickets.
    /// </summary>
    /// <remarks>
    /// Restricted to users with the Admin role.
    /// </remarks>
    [HttpGet("closed")]
    [Authorize(Roles = "Admin")]
    [ProducesResponseType(typeof(IEnumerable<TicketListItemDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<TicketListItemDto>>> GetClosedTickets()
    {
        var result = await ticketService.GetClosedTicketsAsync();
        if (!result.IsSuccess) return HandleErrors(result);
        return Ok(result.Value);
    }

    /// <summary>
    /// Retrieves details of a specific ticket.
    /// </summary>
    [HttpGet("{ticketId}")]
    [Authorize]
    [AllowBanned]
    [ProducesResponseType(typeof(TicketDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(void), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(void), StatusCodes.Status404NotFound)]
    public async Task<ActionResult<TicketDto>> GetTicket(Guid ticketId)
    {
        var result = await ticketService.GetTicketAsync(GetUserId(), ticketId);
        if (!result.IsSuccess) return HandleErrors(result);
        return Ok(result.Value);
    }

    /// <summary>
    /// Sends an administrator reply to a ticket.
    /// </summary>
    /// <remarks>
    /// Restricted to users with the Admin role.
    /// </remarks>
    [HttpPost("reply")]
    [Authorize(Roles = "Admin")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<ActionResult> ReplyToTicket(ReplyToTicketRequestModel request)
    {
        var result = await ticketService.ReplyToTicketAsync(GetUserId(), mapper.Map<ReplyToTicketDto>(request));
        if (!result.IsSuccess) return HandleErrors(result);
        return NoContent();
    }

    /// <summary>
    /// Adds a new message to an existing ticket from the user's side.
    /// </summary>
    [HttpPost("{ticketId}/message")]
    [Authorize]
    [AllowBanned]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(void), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(void), StatusCodes.Status404NotFound)]
    public async Task<ActionResult> AddUserMessage(Guid ticketId, [FromBody] AddUserMessageRequestModel request)
    {
        var dto = new CreateTicketDto { TicketId = ticketId, Message = request.Message };
        var result = await ticketService.CreateTicketAsync(GetUserId(), dto);
        if (!result.IsSuccess) return HandleErrors(result);
        return NoContent();
    }

    /// <summary>
    /// Closes a support ticket.
    /// </summary>
    /// <remarks>
    /// Restricted to users with the Admin role.
    /// </remarks>
    [HttpPatch("{ticketId}/close")]
    [Authorize(Roles = "Admin")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<ActionResult> CloseTicket(Guid ticketId)
    {
        var result = await ticketService.CloseTicketAsync(ticketId);
        if (!result.IsSuccess) return HandleErrors(result);
        return NoContent();
    }
}

public record AddUserMessageRequestModel(string Message);
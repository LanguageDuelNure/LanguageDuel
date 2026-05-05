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
    [HttpPost]
    [Authorize]
    [AllowBanned] // User can create tickets while banned
    [ProducesResponseType(typeof(CreateTicketDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status404NotFound)]
    public async Task<ActionResult<CreateTicketDto>> CreateTicket(CreateTicketRequestModel request)
    {
        var result = await ticketService.CreateTicketAsync(GetUserId(), mapper.Map<CreateTicketDto>(request));
        if (!result.IsSuccess) return HandleErrors(result);
        return Ok(result.Value);
    }

    [HttpGet]
    [Authorize]
    [AllowBanned] // <--- ADDED: So banned users can fetch their ticket list
    [ProducesResponseType(typeof(IEnumerable<TicketListItemDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status404NotFound)]
    public async Task<ActionResult<IEnumerable<TicketListItemDto>>> GetTicketsByUser()
    {
        var result = await ticketService.GetTicketsByUserAsync(GetUserId());
        if (!result.IsSuccess) return HandleErrors(result);
        return Ok(result.Value);
    }

    [HttpGet("open")]
    [Authorize(Roles = "Admin")]
    [ProducesResponseType(typeof(IEnumerable<TicketListItemDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<TicketListItemDto>>> GetOpenTickets()
    {
        var result = await ticketService.GetOpenTicketsAsync();
        if (!result.IsSuccess) return HandleErrors(result);
        return Ok(result.Value);
    }

    [HttpGet("in-progress")]
    [Authorize(Roles = "Admin")]
    [ProducesResponseType(typeof(IEnumerable<TicketListItemDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<TicketListItemDto>>> GetInProgressTickets()
    {
        var result = await ticketService.GetInProgressTicketsAsync();
        if (!result.IsSuccess) return HandleErrors(result);
        return Ok(result.Value);
    }

    [HttpGet("closed")]
    [Authorize(Roles = "Admin")]
    [ProducesResponseType(typeof(IEnumerable<TicketListItemDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<TicketListItemDto>>> GetClosedTickets()
    {
        var result = await ticketService.GetClosedTicketsAsync();
        if (!result.IsSuccess) return HandleErrors(result);
        return Ok(result.Value);
    }

    [HttpGet("{ticketId}")]
    [Authorize]
    [AllowBanned] // <--- ADDED: So banned users can open and read a specific ticket
    [ProducesResponseType(typeof(TicketDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status404NotFound)]
    public async Task<ActionResult<TicketDto>> GetTicket(Guid ticketId)
    {
        var result = await ticketService.GetTicketAsync(GetUserId(), ticketId);
        if (!result.IsSuccess) return HandleErrors(result);
        return Ok(result.Value);
    }

    [HttpPost("reply")]
    [Authorize(Roles = "Admin")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<ActionResult> ReplyToTicket(ReplyToTicketRequestModel request)
    {
        var result = await ticketService.ReplyToTicketAsync(GetUserId(), mapper.Map<ReplyToTicketDto>(request));
        if (!result.IsSuccess) return HandleErrors(result);
        return NoContent();
    }

    [HttpPost("{ticketId}/message")]
    [Authorize]
    [AllowBanned] // Banned users can still message on their own ticket
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status404NotFound)]
    public async Task<ActionResult> AddUserMessage(Guid ticketId, [FromBody] AddUserMessageRequestModel request)
    {
        var dto = new CreateTicketDto { TicketId = ticketId, Message = request.Message };
        var result = await ticketService.CreateTicketAsync(GetUserId(), dto);
        if (!result.IsSuccess) return HandleErrors(result);
        return NoContent();
    }

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
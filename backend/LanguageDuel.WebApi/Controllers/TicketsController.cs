using System.Security.Claims;
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
    /// Create ticket or reply to ticket (only for user)
    /// </summary>
    /// <remarks>
    /// Error keys:
    /// - NOT_FOUND
    /// - BAD_REQUEST
    /// - UNEXPECTED_ERROR
    /// </remarks>
    [HttpPost]
    [Authorize]
    [AllowBanned]
    [ProducesResponseType(typeof(CreateTicketDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status404NotFound)]
    public async Task<ActionResult<CreateTicketDto>> CreateTicket(CreateTicketRequestModel request)
    {
        var result = await ticketService.CreateTicketAsync(GetUserId(), mapper.Map<CreateTicketDto>(request));
        if (!result.IsSuccess)
        {
            return HandleErrors(result);
        }

        return Ok(result.Value);
    }
    
    /// <remarks>
    /// Error keys:
    /// - UNEXPECTED_ERROR
    /// </remarks>
    [HttpGet]
    [Authorize]
    [ProducesResponseType(typeof(IEnumerable<TicketListItemDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status404NotFound)]
    public async Task<ActionResult<IEnumerable<TicketListItemDto>>> GetTicketsByUser()
    {
        var result = await ticketService.GetTicketsByUserAsync(GetUserId());
        if (!result.IsSuccess)
        {
            return HandleErrors(result);
        }

        return Ok(result.Value);
    }
    
    /// <summary>
    /// Get open tickets (only for admin)
    /// </summary>
    /// <remarks>
    /// Error keys:
    /// - UNEXPECTED_ERROR
    /// </remarks>
    [HttpGet("open")]
    [Authorize(Roles = "Admin")]
    [ProducesResponseType(typeof(IEnumerable<TicketListItemDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status404NotFound)]
    public async Task<ActionResult<IEnumerable<TicketListItemDto>>> GetOpenTickets()
    {
        var result = await ticketService.GetOpenTicketsAsync();
        if (!result.IsSuccess)
        {
            return HandleErrors(result);
        }

        return Ok(result.Value);
    }
    
    /// <summary>
    /// Get in progress tickets (only for admin)
    /// </summary>
    /// <remarks>
    /// Error keys:
    /// - UNEXPECTED_ERROR
    /// </remarks>
    [HttpGet("in-progress")]
    [Authorize(Roles = "Admin")]
    [ProducesResponseType(typeof(IEnumerable<TicketListItemDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status404NotFound)]
    public async Task<ActionResult<IEnumerable<TicketListItemDto>>> GetInProgressTickets()
    {
        var result = await ticketService.GetInProgressTicketsAsync();
        if (!result.IsSuccess)
        {
            return HandleErrors(result);
        }

        return Ok(result.Value);
    }
    
    /// <summary>
    /// Get closed tickets (only for admin)
    /// </summary>
    /// <remarks>
    /// Error keys:
    /// - UNEXPECTED_ERROR
    /// </remarks>
    [HttpGet("closed")]
    [Authorize(Roles = "Admin")]
    [ProducesResponseType(typeof(IEnumerable<TicketListItemDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status404NotFound)]
    public async Task<ActionResult<IEnumerable<TicketListItemDto>>> GetClosedTickets()
    {
        var result = await ticketService.GetClosedTicketsAsync();
        if (!result.IsSuccess)
        {
            return HandleErrors(result);
        }

        return Ok(result.Value);
    }
    
    /// <remarks>
    /// Error keys:
    /// - NOT_FOUND
    /// - UNEXPECTED_ERROR
    /// </remarks>
    [HttpGet("{ticketId}")]
    [Authorize]
    [ProducesResponseType(typeof(TicketDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status404NotFound)]
    public async Task<ActionResult<TicketDto>> GetTicket(Guid ticketId)
    {
        var result = await ticketService.GetTicketAsync(GetUserId(), ticketId);
        if (!result.IsSuccess)
        {
            return HandleErrors(result);
        }

        return Ok(result.Value);
    }
    
    /// <summary>
    /// Reply to the ticket (only for admin)
    /// </summary>
    /// <remarks>
    /// Error keys:
    /// - NOT_FOUND
    /// - BAD_REQUEST
    /// - UNEXPECTED_ERROR
    /// </remarks>
    [HttpPost("reply")]
    [Authorize(Roles = "Admin")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status404NotFound)]
    public async Task<ActionResult> ReplyToTicket(ReplyToTicketRequestModel request)
    {
        var result = await ticketService.ReplyToTicketAsync(GetUserId(), mapper.Map<ReplyToTicketDto>(request));
        if (!result.IsSuccess)
        {
            return HandleErrors(result);
        }

        return NoContent();
    }
    
    /// <remarks>
    /// Error keys:
    /// - NOT_FOUND
    /// - BAD_REQUEST
    /// - UNEXPECTED_ERROR
    /// </remarks>
    [HttpPatch("{ticketId}/close")]
    [Authorize(Roles = "Admin")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status404NotFound)]
    public async Task<ActionResult> CloseTicket(Guid ticketId)
    {
        var result = await ticketService.CloseTicketAsync(ticketId);
        if (!result.IsSuccess)
        {
            return HandleErrors(result);
        }

        return NoContent();
    }
}
using AutoMapper;
using LanguageDuel.Application.Dtos.Results;
using LanguageDuel.Application.Dtos.Tickets;
using LanguageDuel.Application.Dtos.Users;
using LanguageDuel.Application.Repositories;
using LanguageDuel.Domain.Entities;

namespace LanguageDuel.Application.Services.Tickets;

public class TicketService(IUnitOfWork unitOfWork, ITicketRepository ticketRep, ITicketMessageRepository ticketMessageRep, IMapper mapper, IUserService userService) : ITicketService
{
    public async Task<Result<CreateTicketDto>> CreateTicketAsync(Guid userId, CreateTicketDto dto)
    {
        var finalTicketId = dto.TicketId;
        if (dto.TicketId == null)
        {
            var ticket = new Ticket()
            {
                ApplicationUserId = userId,
                Messages =
                [
                    new TicketMessage()
                    {
                        Message = dto.Message,
                        ApplicationUserId = userId,
                    }
                ]
            };
            ticketRep.Add(ticket);
            finalTicketId = ticket.Id;
        }
        else
        {
            var ticket = await ticketRep.GetAsync(dto.TicketId.Value);
            if (ticket == null)
            {
                return new Result<CreateTicketDto>()
                {
                    Errors =
                    [
                        new Error
                        {
                            Key = ErrorKey.NotFound,
                            Message = "Ticket not found."
                        }
                    ]
                };
            }

            if (ticket.ApplicationUserId != userId)
            {
                return new Result<CreateTicketDto>()
                {
                    Errors =
                    [
                        new Error
                        {
                            Key = ErrorKey.BadRequest,
                            Message = "User is not the owner of the ticket."
                        }
                    ]
                };
            }
            
            if (ticket.Status == TicketStatus.Closed)
            {
                return new Result<CreateTicketDto>()
                {
                    Errors =
                    [
                        new Error()
                        {
                            Key = ErrorKey.BadRequest,
                            Message = "Cannot write to a closed ticket."
                        }
                    ]
                };
            }
            
            ticketMessageRep.Add(new TicketMessage
            {
                TicketId = dto.TicketId.Value,
                Message = dto.Message,
                ApplicationUserId = userId,
            });
        }
        
        await unitOfWork.CommitAsync();
        
        return new Result<CreateTicketDto>
        {
            Value = new CreateTicketDto
            {
                TicketId = finalTicketId,
                Message = dto.Message,
            },
        };
    }

    public async Task<Result<IEnumerable<TicketListItemDto>>> GetTicketsByUserAsync(Guid userId)
    {
        var tickets = await ticketRep.GetTicketsByUserAsync(userId);
        var dtos = mapper.Map<IEnumerable<TicketListItemDto>>(tickets).ToList();
        await AssignUserNameAsync(dtos);
        return new Result<IEnumerable<TicketListItemDto>>
        {
            Value = dtos,
        };
    }
    
    public async Task<Result<TicketDto>> GetTicketAsync(Guid userId, Guid ticketId)
    {
        var ticket = await ticketRep.GetTicketAsync(ticketId);
        if (ticket == null)
        {
            return new Result<TicketDto>()
            {
                Errors =
                [
                    new Error
                    {
                        Key = ErrorKey.NotFound,
                        Message = "Ticket not found."
                    }
                ]
            };
        }
        var dto = mapper.Map<TicketDto>(ticket);
        IdentifyMessageOwners(dto, userId);
        dto.UserName = await GetUserNameAsync(dto.UserId);
        return new Result<TicketDto>
        {
            Value = dto,
        };
    }

    public async Task<Result> ReplyToTicketAsync(Guid adminId, ReplyToTicketDto dto)
    {
        var ticket = await ticketRep.GetAsync(dto.TicketId);
        if (ticket == null)
        {
            return new Result<CreateTicketDto>()
            {
                Errors =
                [
                    new Error
                    {
                        Key = ErrorKey.NotFound,
                        Message = "Ticket not found."
                    }
                ]
            };
        }

        if (ticket.Status == TicketStatus.Closed)
        {
            return new Result<CreateTicketDto>()
            {
                Errors =
                [
                    new Error()
                    {
                        Key = ErrorKey.BadRequest,
                        Message = "Cannot reply to a closed ticket."
                    }
                ]
            };
        }
        
        ticketMessageRep.Add(new TicketMessage
        {
            TicketId = dto.TicketId,
            Message = dto.Message,
            ApplicationUserId = adminId,
        });
        
        if (ticket.Status == TicketStatus.Open)
        {
            ticket.Status = TicketStatus.InProgress;
        }
        
        await unitOfWork.CommitAsync();

        return new Result();
    }
    
    public async Task<Result<IEnumerable<TicketListItemDto>>> GetOpenTicketsAsync()
    {
        var tickets = await ticketRep.GetTicketsAsync([TicketStatus.Open]);
        var dtos = mapper.Map<IEnumerable<TicketListItemDto>>(tickets).ToList();
        await AssignUserNameAsync(dtos);
        return new Result<IEnumerable<TicketListItemDto>>
        {
            Value = dtos,
        };
    }
    
    public async Task<Result<IEnumerable<TicketListItemDto>>> GetInProgressTicketsAsync()
    {
        var tickets = await ticketRep.GetTicketsAsync([TicketStatus.InProgress]);
        var dtos = mapper.Map<IEnumerable<TicketListItemDto>>(tickets).ToList();
        await AssignUserNameAsync(dtos);
        return new Result<IEnumerable<TicketListItemDto>>
        {
            Value = dtos,
        };
    }
    
    public async Task<Result<IEnumerable<TicketListItemDto>>> GetClosedTicketsAsync()
    {
        var tickets = await ticketRep.GetTicketsAsync([TicketStatus.Closed]);
        var dtos = mapper.Map<IEnumerable<TicketListItemDto>>(tickets).ToList();
        await AssignUserNameAsync(dtos);
        return new Result<IEnumerable<TicketListItemDto>>
        {
            Value = dtos,
        };
    }
    
    public async Task<Result> CloseTicketAsync(Guid ticketId)
    {
        var ticket = await ticketRep.GetAsync(ticketId);
        if (ticket == null)
        {
            return new Result()
            {
                Errors =
                [
                    new Error
                    {
                        Key = ErrorKey.NotFound,
                        Message = "Ticket not found."
                    }
                ]
            };
        }

        if (ticket.Status == TicketStatus.Open)
        {
            return new Result()
            {
                Errors =
                [
                    new Error
                    {
                        Key = ErrorKey.BadRequest,
                        Message = "Cannot close a ticket without a response."
                    }
                ]
            };
        }
        
        ticket.Status = TicketStatus.Closed;
        await unitOfWork.CommitAsync();
        
        return new Result();
    }

    private static void IdentifyMessageOwners(TicketDto dto, Guid userId)
    {
        foreach (var ticketMessage in dto.Messages)
        {
            ticketMessage.IsMine = userId == ticketMessage.UserId;
        }
    }
    
    private async Task AssignUserNameAsync(IEnumerable<TicketListItemDto> tickets)
    {
        foreach (var ticket in tickets)
        {
            ticket.UserName = await GetUserNameAsync(ticket.UserId);
        }
    }
    
    private async Task<string> GetUserNameAsync(Guid userId)
    {
        var getUserResult = await userService.GetUserDtoAsync(userId);

        var user = getUserResult.Value;
        return user.Name;
    }
}
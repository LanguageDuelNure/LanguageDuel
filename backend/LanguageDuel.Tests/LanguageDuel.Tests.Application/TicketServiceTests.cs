using LanguageDuel.Application.Dtos.Results;
using LanguageDuel.Application.Dtos.Tickets;
using LanguageDuel.Application.Dtos.Users;
using LanguageDuel.Application.Repositories;
using LanguageDuel.Application.Services;
using LanguageDuel.Application.Services.Tickets;
using LanguageDuel.Application.Services.Users;
using LanguageDuel.Domain.Entities;
using Moq;
using Xunit;

namespace LanguageDuel.Tests.Application;

public class TicketServiceTests : BaseServiceTests
{
    private readonly Mock<IUnitOfWork> _unitOfWorkMock = new();
    private readonly Mock<ITicketRepository> _ticketRepMock = new();
    private readonly Mock<IRepository<TicketMessage>> _ticketMessageRepMock = new();
    private readonly Mock<IUserService> _userServiceMock = new();
    private readonly TicketService _service;

    public TicketServiceTests()
    {
        _service = new TicketService(
            _unitOfWorkMock.Object,
            _ticketRepMock.Object,
            _ticketMessageRepMock.Object,
            GetMapper(),
            _userServiceMock.Object);
    }

    [Fact]
    public async Task CreateTicketAsync_NewTicket_Success()
    {
        var userId = Guid.NewGuid();
        var dto = new CreateTicketDto { Message = "Hello", TicketId = null };

        var result = await _service.CreateTicketAsync(userId, dto);

        Assert.True(result.IsSuccess);
        _ticketRepMock.Verify(x => x.Add(It.IsAny<Ticket>()), Times.Once);
        _unitOfWorkMock.Verify(x => x.CommitAsync(), Times.Once);
    }

    [Fact]
    public async Task CreateTicketAsync_ClosedTicket_ReturnsBadRequest()
    {
        var userId = Guid.NewGuid();
        var ticketId = Guid.NewGuid();
        var dto = new CreateTicketDto { Message = "More text", TicketId = ticketId };
        var ticket = new Ticket { Id = ticketId, ApplicationUserId = userId, Status = TicketStatus.Closed };

        _ticketRepMock.Setup(x => x.GetAsync(ticketId)).ReturnsAsync(ticket);

        var result = await _service.CreateTicketAsync(userId, dto);

        Assert.False(result.IsSuccess);
        Assert.Equal(ErrorKey.BadRequest, result.Errors.First().Key);
    }

    [Fact]
    public async Task GetTicketAsync_Success_IdentifiesOwners()
    {
        var userId = Guid.NewGuid();
        var ticketId = Guid.NewGuid();
        var ticket = new Ticket
        {
            Id = ticketId,
            ApplicationUserId = userId,
            Messages = [new TicketMessage { ApplicationUserId = userId, Message = "Text" }]
        };

        _ticketRepMock.Setup(x => x.GetTicketAsync(ticketId)).ReturnsAsync(ticket);
        _userServiceMock.Setup(x => x.GetUserDtoAsync(userId))
            .ReturnsAsync(new Result<UserDto> { Value = new UserDto { Name = "Tester" } });

        var result = await _service.GetTicketAsync(userId, ticketId);

        Assert.True(result.IsSuccess);
        Assert.True(result.Value.Messages.First().IsMine);
        Assert.Equal("Tester", result.Value.UserName);
    }

    [Fact]
    public async Task GetTicketAsync_NotFound_ReturnsError()
    {
        var ticketId = Guid.NewGuid();
        _ticketRepMock.Setup(x => x.GetTicketAsync(ticketId)).ReturnsAsync((Ticket)null!);

        var result = await _service.GetTicketAsync(Guid.NewGuid(), ticketId);

        Assert.False(result.IsSuccess);
        Assert.Equal(ErrorKey.NotFound, result.Errors.First().Key);
    }

    [Fact]
    public async Task ReplyToTicketAsync_Success_ChangesStatusToInProgress()
    {
        var adminId = Guid.NewGuid();
        var ticketId = Guid.NewGuid();
        var ticket = new Ticket { Id = ticketId, Status = TicketStatus.Open };
        var dto = new ReplyToTicketDto { TicketId = ticketId, Message = "Admin reply" };

        _ticketRepMock.Setup(x => x.GetAsync(ticketId)).ReturnsAsync(ticket);

        var result = await _service.ReplyToTicketAsync(adminId, dto);

        Assert.True(result.IsSuccess);
        Assert.Equal(TicketStatus.InProgress, ticket.Status);
        _ticketMessageRepMock.Verify(x => x.Add(It.IsAny<TicketMessage>()), Times.Once);
    }

    [Fact]
    public async Task ReplyToTicketAsync_ClosedTicket_ReturnsError()
    {
        var ticketId = Guid.NewGuid();
        var ticket = new Ticket { Id = ticketId, Status = TicketStatus.Closed };
        _ticketRepMock.Setup(x => x.GetAsync(ticketId)).ReturnsAsync(ticket);

        var result = await _service.ReplyToTicketAsync(Guid.NewGuid(), new ReplyToTicketDto { TicketId = ticketId });

        Assert.False(result.IsSuccess);
        Assert.Equal(ErrorKey.BadRequest, result.Errors.First().Key);
    }

    [Fact]
    public async Task CloseTicketAsync_Success_UpdatesStatus()
    {
        var ticketId = Guid.NewGuid();
        var ticket = new Ticket { Id = ticketId, Status = TicketStatus.InProgress };

        _ticketRepMock.Setup(x => x.GetAsync(ticketId)).ReturnsAsync(ticket);

        var result = await _service.CloseTicketAsync(ticketId);

        Assert.True(result.IsSuccess);
        Assert.Equal(TicketStatus.Closed, ticket.Status);
        _unitOfWorkMock.Verify(x => x.CommitAsync(), Times.Once);
    }

    [Fact]
    public async Task CloseTicketAsync_WithoutResponse_ReturnsError()
    {
        var ticketId = Guid.NewGuid();
        var ticket = new Ticket { Id = ticketId, Status = TicketStatus.Open };
        _ticketRepMock.Setup(x => x.GetAsync(ticketId)).ReturnsAsync(ticket);

        var result = await _service.CloseTicketAsync(ticketId);

        Assert.False(result.IsSuccess);
        Assert.Equal(ErrorKey.BadRequest, result.Errors.First().Key);
    }

    [Fact]
    public async Task GetOpenTicketsAsync_Success_ReturnsList()
    {
        var userId = Guid.NewGuid();
        var tickets = new List<Ticket> { new() { Id = Guid.NewGuid(), ApplicationUserId = userId, Status = TicketStatus.Open } };

        _ticketRepMock.Setup(x => x.GetTicketsAsync(It.IsAny<IEnumerable<TicketStatus>>())).ReturnsAsync(tickets);
        _userServiceMock.Setup(x => x.GetUserDtoAsync(userId))
            .ReturnsAsync(new Result<UserDto> { Value = new UserDto { Name = "User" } });

        var result = await _service.GetOpenTicketsAsync();

        Assert.True(result.IsSuccess);
        Assert.Single(result.Value);
        Assert.Equal("User", result.Value.First().UserName);
    }

    [Fact]
    public async Task GetTicketsByUserAsync_EmptyList_ReturnsEmpty()
    {
        var userId = Guid.NewGuid();
        _ticketRepMock.Setup(x => x.GetTicketsByUserAsync(userId)).ReturnsAsync(new List<Ticket>());

        var result = await _service.GetTicketsByUserAsync(userId);

        Assert.True(result.IsSuccess);
        Assert.Empty(result.Value);
    }
}
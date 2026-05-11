using LanguageDuel.Application.Dtos.Results;
using LanguageDuel.Application.Dtos.Users;
using LanguageDuel.Application.Services;
using LanguageDuel.Application.Services.Users;
using LanguageDuel.Domain.Common;
using LanguageDuel.Domain.Entities;
using LanguageDuel.Infrastructure.Services;
using Microsoft.AspNetCore.Identity;
using Moq;
using Xunit;

namespace LanguageDuel.Tests.Application;

public class UserServiceTests : BaseServiceTests
{
    private readonly Mock<UserManager<ApplicationUser>> _userManagerMock;
    private readonly Mock<IEmailSender> _emailSenderMock = new();
    private readonly Mock<IJwtTokenService> _jwtTokenServiceMock = new();
    private readonly Mock<IFileService> _fileServiceMock = new();
    private readonly UserService _service;

    public UserServiceTests()
    {
        _userManagerMock = MockUserManager();
        _service = new UserService(
            _userManagerMock.Object,
            _emailSenderMock.Object,
            _jwtTokenServiceMock.Object,
            GetMapper(),
            _fileServiceMock.Object);
    }

    private static Mock<UserManager<ApplicationUser>> MockUserManager()
    {
        var store = new Mock<IUserStore<ApplicationUser>>();
        return new Mock<UserManager<ApplicationUser>>(store.Object, null!, null!, null!, null!, null!, null!, null!, null!);
    }

    [Fact]
    public async Task RegisterUserAsync_Success_ReturnsUserId()
    {
        var dto = new RegisterUserDto { Email = "test@test.com", Password = "Password123!", Name = "Test" };
        _userManagerMock.Setup(x => x.CreateAsync(It.IsAny<ApplicationUser>(), dto.Password))
            .ReturnsAsync(IdentityResult.Success);
        _userManagerMock.Setup(x => x.AddToRoleAsync(It.IsAny<ApplicationUser>(), DefaultRoles.UserRole.Name!))
            .ReturnsAsync(IdentityResult.Success);

        var result = await _service.RegisterUserAsync(dto);

        Assert.True(result.IsSuccess);
        Assert.NotNull(result.Value);
        _emailSenderMock.Verify(x => x.SendEmailAsync(dto.Email, It.IsAny<string>(), It.IsAny<string>()), Times.Once);
    }

    [Fact]
    public async Task RegisterUserAsync_UserExists_ReturnsAlreadyExistsError()
    {
        var dto = new RegisterUserDto { Email = "exists@test.com", Password = "Password123!" };
        _userManagerMock.Setup(x => x.CreateAsync(It.IsAny<ApplicationUser>(), It.IsAny<string>()))
            .ReturnsAsync(IdentityResult.Failed(new IdentityError { Code = "DuplicateUserName" }));

        var result = await _service.RegisterUserAsync(dto);

        Assert.False(result.IsSuccess);
        Assert.Equal(ErrorKey.AlreadyExists, result.Errors.First().Key);
    }

    [Fact]
    public async Task LoginAsync_Success_ReturnsJwtToken()
    {
        var dto = new LoginUserDto { Email = "test@test.com", Password = "Password123!" };
        var user = new ApplicationUser { Id = Guid.NewGuid(), Email = dto.Email, EmailConfirmed = true };
        
        _userManagerMock.Setup(x => x.FindByEmailAsync(dto.Email)).ReturnsAsync(user);
        _userManagerMock.Setup(x => x.CheckPasswordAsync(user, dto.Password)).ReturnsAsync(true);
        _userManagerMock.Setup(x => x.GetRolesAsync(user)).ReturnsAsync(["User"]);
        _jwtTokenServiceMock.Setup(x => x.GenerateToken(user.Id, "User")).Returns("fake-jwt-token");

        var result = await _service.LoginAsync(dto);

        Assert.True(result.IsSuccess);
        Assert.Equal("fake-jwt-token", result.Value.JwtToken);
        Assert.True(result.Value.EmailConfirmed);
    }

    [Fact]
    public async Task LoginAsync_UserNotFound_ReturnsNotFoundError()
    {
        var dto = new LoginUserDto { Email = "notfound@test.com", Password = "AnyPassword" };
        _userManagerMock.Setup(x => x.FindByEmailAsync(dto.Email)).ReturnsAsync((ApplicationUser)null!);

        var result = await _service.LoginAsync(dto);

        Assert.False(result.IsSuccess);
        Assert.Equal(ErrorKey.NotFound, result.Errors.First().Key);
    }

    [Fact]
    public async Task ConfirmEmailAsync_ValidCode_ReturnsToken()
    {
        var user = new ApplicationUser { Id = Guid.NewGuid(), VerificationCode = "123456", EmailConfirmed = false };
        var dto = new ConfirmEmailDto { UserId = user.Id, Code = "123456" };

        _userManagerMock.Setup(x => x.FindByIdAsync(user.Id.ToString())).ReturnsAsync(user);
        _userManagerMock.Setup(x => x.GetRolesAsync(user)).ReturnsAsync(["User"]);
        _jwtTokenServiceMock.Setup(x => x.GenerateToken(user.Id, "User")).Returns("jwt-token");

        var result = await _service.ConfirmEmailAsync(dto);

        Assert.True(result.IsSuccess);
        Assert.True(user.EmailConfirmed);
        Assert.Equal("jwt-token", result.Value.JwtToken);
    }

    [Fact]
    public async Task ConfirmEmailAsync_InvalidCode_ReturnsIncorrectError()
    {
        var user = new ApplicationUser { Id = Guid.NewGuid(), VerificationCode = "123456" };
        var dto = new ConfirmEmailDto { UserId = user.Id, Code = "wrong-code" };

        _userManagerMock.Setup(x => x.FindByIdAsync(user.Id.ToString())).ReturnsAsync(user);

        var result = await _service.ConfirmEmailAsync(dto);

        Assert.False(result.IsSuccess);
        Assert.Equal(ErrorKey.Incorrect, result.Errors.First().Key);
    }

    [Fact]
    public async Task ResendRegistrationEmailAsync_Success_SendsNewCode()
    {
        var userId = Guid.NewGuid();
        var user = new ApplicationUser { Id = userId, Email = "test@test.com", EmailConfirmed = false };
        _userManagerMock.Setup(x => x.FindByIdAsync(userId.ToString())).ReturnsAsync(user);
        _userManagerMock.Setup(x => x.UpdateAsync(user)).ReturnsAsync(IdentityResult.Success);

        var result = await _service.ResendRegistrationEmailAsync(userId);

        Assert.True(result.IsSuccess);
        _emailSenderMock.Verify(x => x.SendEmailAsync(user.Email, It.IsAny<string>(), It.IsAny<string>()), Times.Once);
    }

    [Fact]
    public async Task ResendRegistrationEmailAsync_UserNotFound_ReturnsNotFoundError()
    {
        var userId = Guid.NewGuid();
        _userManagerMock.Setup(x => x.FindByIdAsync(userId.ToString())).ReturnsAsync((ApplicationUser)null!);

        var result = await _service.ResendRegistrationEmailAsync(userId);

        Assert.False(result.IsSuccess);
        Assert.Equal(ErrorKey.NotFound, result.Errors.First().Key);
    }
    
    [Fact]
    public async Task BanUserAsync_Success_ReturnsSuccess()
    {
        var userId = Guid.NewGuid();
        var user = new ApplicationUser { Id = userId };
        var dto = new BanUserDto { Days = 7, Reason = "Spam" };

        _userManagerMock.Setup(x => x.FindByIdAsync(userId.ToString())).ReturnsAsync(user);
        _userManagerMock.Setup(x => x.SetLockoutEndDateAsync(user, It.IsAny<DateTimeOffset?>()))
            .ReturnsAsync(IdentityResult.Success);
        _userManagerMock.Setup(x => x.UpdateAsync(user)).ReturnsAsync(IdentityResult.Success);

        var result = await _service.BanUserAsync(userId, dto);

        Assert.True(result.IsSuccess);
        Assert.Equal("Spam", user.BanReason);
    }

    [Fact]
    public async Task BanUserAsync_UserNotFound_ReturnsNotFoundError()
    {
        var userId = Guid.NewGuid();
        _userManagerMock.Setup(x => x.FindByIdAsync(userId.ToString())).ReturnsAsync((ApplicationUser)null!);

        var result = await _service.BanUserAsync(userId, new BanUserDto());

        Assert.False(result.IsSuccess);
        Assert.Equal(ErrorKey.NotFound, result.Errors.First().Key);
    }

    [Fact]
    public async Task UnbanUserAsync_Success_RemovesLockout()
    {
        var userId = Guid.NewGuid();
        var user = new ApplicationUser { Id = userId, LockoutEnd = DateTimeOffset.UtcNow.AddDays(1) };

        _userManagerMock.Setup(x => x.FindByIdAsync(userId.ToString())).ReturnsAsync(user);
        _userManagerMock.Setup(x => x.SetLockoutEndDateAsync(user, null))
            .ReturnsAsync(IdentityResult.Success);

        var result = await _service.UnbanUserAsync(userId);

        Assert.True(result.IsSuccess);
    }

    [Fact]
    public async Task UpdateUserProfileAsync_Success_UpdatesName()
    {
        var userId = Guid.NewGuid();
        var user = new ApplicationUser { Id = userId, Name = "Old Name" };
        var dto = new UpdateUserProfileDto { Name = "New Name", Icon = null };

        _userManagerMock.Setup(x => x.FindByIdAsync(userId.ToString())).ReturnsAsync(user);
        _userManagerMock.Setup(x => x.UpdateAsync(user)).ReturnsAsync(IdentityResult.Success);

        var result = await _service.UpdateUserProfileAsync(userId, dto);

        Assert.True(result.IsSuccess);
        Assert.Equal("New Name", user.Name);
    }

    [Fact]
    public async Task UpdateUserProfileAsync_InvalidFileSize_ReturnsBadRequest()
    {
        var userId = Guid.NewGuid();
        var user = new ApplicationUser { Id = userId };
        using var stream = new MemoryStream();
        var dto = new UpdateUserProfileDto 
        { 
            Name = "Name", 
            Icon = stream, 
            IconName = "test.png" 
        };
        
        _userManagerMock.Setup(x => x.FindByIdAsync(userId.ToString())).ReturnsAsync(user);
        _fileServiceMock.Setup(x => x.IsValidSize(dto.Icon)).Returns(false);

        var result = await _service.UpdateUserProfileAsync(userId, dto);

        Assert.False(result.IsSuccess);
        Assert.Equal(ErrorKey.BadRequest, result.Errors.First().Key);
    }

    [Fact]
    public async Task UpdateUserStatisticAsync_Win_IncrementsTotalAndWins()
    {
        var userId = Guid.NewGuid();
        var user = new ApplicationUser { Id = userId, TotalGames = 5, TotalWins = 2 };

        _userManagerMock.Setup(x => x.FindByIdAsync(userId.ToString())).ReturnsAsync(user);

        var result = await _service.UpdateUserStatisticAsync(userId, isWin: true);

        Assert.True(result.IsSuccess);
        Assert.Equal(6, user.TotalGames);
        Assert.Equal(3, user.TotalWins);
    }

    [Fact]
    public async Task UpdateUserStatisticAsync_Loss_IncrementsOnlyTotal()
    {
        var userId = Guid.NewGuid();
        var user = new ApplicationUser { Id = userId, TotalGames = 5, TotalWins = 2 };

        _userManagerMock.Setup(x => x.FindByIdAsync(userId.ToString())).ReturnsAsync(user);

        var result = await _service.UpdateUserStatisticAsync(userId, isWin: false);

        Assert.True(result.IsSuccess);
        Assert.Equal(6, user.TotalGames);
        Assert.Equal(2, user.TotalWins);
    }
}
using AutoMapper;
using LanguageDuel.Application.Dtos.Results;
using LanguageDuel.Application.Dtos.Users;
using LanguageDuel.Application.Services;
using LanguageDuel.WebApi.Requests.Tickets;
using LanguageDuel.WebApi.Requests.Users;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace LanguageDuel.WebApi.Controllers;

[Route("api/[controller]")]
[ApiController]
public class UsersController(IUserService userService, IMapper mapper) : BaseController
{
    /// <remarks>
    /// Error keys:
    /// - INVALID_STRING_LENGTH (with Min and Max parameters)
    /// - ALREADY_EXISTS
    /// - INCORRECT (for incorrect email or not strong password (with MinNumberOfUppercaseCharacters and MaxNumberOfUppercaseCharacters))
    /// - DoNotMatch (with OtherProperty)
    /// - UNEXPECTED_ERROR
    /// </remarks>
    [HttpPost("register")]
    [ProducesResponseType(typeof(RegisterResultDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status409Conflict)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status500InternalServerError)]
    public async Task<ActionResult<RegisterResultDto>> RegisterUser(RegisterUserRequestModel request)
    {
        var result = await userService.RegisterUserAsync(mapper.Map<RegisterUserDto>(request));
        if (!result.IsSuccess)
        {
            return HandleErrors(result);
        }

        var registerResultDto = result.Value;

        return Accepted(registerResultDto);
    }

    /// <remarks>
    /// Error keys:
    /// - NOT_FOUND
    /// - INCORRECT
    /// - ALREADY_CONFIRMED
    /// - UNEXPECTED_ERROR
    /// </remarks>
    [HttpPost("confirm-email")]
    [ProducesResponseType(typeof(ConfirmEmailResultDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status404NotFound)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status500InternalServerError)]
    public async Task<ActionResult<ConfirmEmailResultDto>> ConfirmEmail(EmailConfirmationRequestModel request)
    {
        var result = await userService.ConfirmEmailAsync(mapper.Map<ConfirmEmailDto>(request));
        if (!result.IsSuccess)
        {
            return HandleErrors(result);
        }

        var confirmEmailResultDto = result.Value;

        return Ok(confirmEmailResultDto);
    }

    /// <remarks>
    /// Error keys:
    /// - NOT_FOUND
    /// - UNEXPECTED_ERROR
    /// </remarks>
    [HttpPost("resend-confirm-email")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status404NotFound)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status500InternalServerError)]
    public async Task<ActionResult> ResendConfirmEmail(ResendEmailConfirmationRequestModel request)
    {
        var result = await userService.ResendRegistrationEmailAsync(request.UserId);

        return !result.IsSuccess ? HandleErrors(result) : NoContent();
    }

    /// <remarks>
    /// Error keys:
    /// - NOT_FOUND
    /// - INCORRECT_LOGIN_OR_PASSWORD
    /// - INVALID_STRING_LENGTH (with min and max parameters)
    /// - INCORRECT (for incorrect email or not strong password (with MinNumberOfUppercaseCharacters and MaxNumberOfUppercaseCharacters))
    /// - UNEXPECTED_ERROR
    /// </remarks>
    [HttpPost("login")]
    [ProducesResponseType(typeof(LoginResultDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status404NotFound)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status500InternalServerError)]
    public async Task<ActionResult<LoginResultDto>> Login(LoginRequestModel request)
    {
        var result = await userService.LoginAsync(mapper.Map<LoginUserDto>(request));

        if (!result.IsSuccess)
        {
            return HandleErrors(result);
        }

        var loginResultDto = result.Value;

        return Ok(loginResultDto);
    }

    /// <remarks>
    /// Error keys:
    /// - BAD_REQUEST (invalid Google token)
    /// - UNEXPECTED_ERROR
    /// </remarks>
    [HttpPost("google-login")]
    [ProducesResponseType(typeof(LoginResultDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status500InternalServerError)]
    public async Task<ActionResult<LoginResultDto>> GoogleLogin(GoogleLoginRequestModel requestModel)
    {
        var result = await userService.HandleGoogleLoginAsync(requestModel.IdToken);

        if (!result.IsSuccess)
        {
            return HandleErrors(result);
        }

        var loginResultDto = result.Value;

        return Ok(loginResultDto);
    }

    /// <remarks>
    /// Error keys:
    /// - NOT_FOUND
    /// - UNEXPECTED_ERROR
    /// </remarks>
    [HttpGet("{userId}")]
    [ProducesResponseType(typeof(UserDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status404NotFound)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status500InternalServerError)]
    public async Task<ActionResult<UserDto>> GetUser(Guid userId)
    {
        var result = await userService.GetUserDtoAsync(userId);
        if (!result.IsSuccess)
        {
            return HandleErrors(result);
        }

        var userDto = result.Value;

        return Ok(userDto);
    }
    
    /// <remarks>
    /// Error keys:
    /// - UNEXPECTED_ERROR
    /// </remarks>
    [HttpGet]
    [Authorize(Roles = "Admin")]
    [ProducesResponseType(typeof(IEnumerable<UserAdminListItemDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status500InternalServerError)]
    public async Task<ActionResult<IEnumerable<UserAdminListItemDto>>> GetAllUsers()
    {
        var result = await userService.GetAllUsersAsync();
        if (!result.IsSuccess)
        {
            return HandleErrors(result);
        }

        return Ok(result.Value);
    }
    
    /// <remarks>
    /// Error keys:
    /// - NOT_FOUND (if language not found)
    /// - UNEXPECTED_ERROR
    /// </remarks>
    [HttpGet("leaderboard")]
    [ProducesResponseType(typeof(IEnumerable<LeaderboardItemDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status404NotFound)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status500InternalServerError)]
    public async Task<ActionResult<IEnumerable<LeaderboardItemDto>>> GetLeaderboard(Guid? languageId)
    {
        var result = await userService.GetLeaderboardAsync(languageId);
        
        if (!result.IsSuccess)
        {
            return HandleErrors(result);
        }

        return Ok(result.Value);
    }

    /// <remarks>
    /// Error keys:
    /// - NOT_FOUND
    /// - BAD_REQUEST
    /// - UNEXPECTED_ERROR
    /// </remarks>
    [HttpPost("{userId}/ban")]
    [Authorize(Roles = "Admin")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status404NotFound)]
    public async Task<ActionResult> BanUser(Guid userId, BanUserRequestModel request)
    {
        var result = await userService.BanUserAsync(userId, mapper.Map<BanUserDto>(request));
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
    [HttpPost("ticket")]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status404NotFound)]
    public async Task<ActionResult> CreateTicket(Guid userId, CreateTicketRequestModel request)
    {
        var result = await userService.BanUserAsync(userId, mapper.Map<BanUserDto>(request));
        if (!result.IsSuccess)
        {
            return HandleErrors(result);
        }

        return NoContent();
    }

    /// <remarks>
    /// Error keys:
    /// - NOT_FOUND
    /// - UNEXPECTED_ERROR
    /// </remarks>
    [HttpPost("{userId}/unban")]
    [Authorize(Roles = "Admin")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status404NotFound)]
    public async Task<ActionResult> UnbanUser(Guid userId)
    {
        var result = await userService.UnbanUserAsync(userId);
        if (!result.IsSuccess)
        {
            return HandleErrors(result);
        }

        return NoContent();
    }
    
    /// <remarks>
    /// Error keys:
    /// - NOT_FOUND
    /// - UNEXPECTED_ERROR
    /// </remarks>
    [HttpPut]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status404NotFound)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status500InternalServerError)]
    public async Task<ActionResult<UserDto>> UpdateUserProfile(UpdateUserProfileRequestModel request)
    {
        await using var stream = request.Icon?.OpenReadStream();
        var dto = new UpdateUserProfileDto
        {
            Icon = stream,
            Name = request.Name,
            IconName = request.Icon?.FileName
        };
        var result = await userService.UpdateUserProfileAsync(GetUserId(), dto);
        if (!result.IsSuccess)
        {
            return HandleErrors(result);
        }

        return NoContent();
    }
}

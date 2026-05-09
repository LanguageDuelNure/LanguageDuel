using AutoMapper;
using LanguageDuel.Application.Dtos.Results;
using LanguageDuel.Application.Dtos.Users;
using LanguageDuel.Application.Services;
using LanguageDuel.WebApi.Requests.Users;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace LanguageDuel.WebApi.Controllers;

[Route("api/[controller]")]
[ApiController]
public class UsersController(IUserService userService, IMapper mapper) : BaseController
{
    /// <summary>
    /// Registers a new user in the system.
    /// </summary>
    /// <remarks>
    /// Error keys:
    /// - **INVALID_STRING_LENGTH**: Provided data exceeds limits (Min/Max).
    /// - **ALREADY_EXISTS**: Email or username is already taken.
    /// - **INCORRECT**: Invalid email format or weak password.
    /// - **DoNotMatch**: Password and confirmation do not match.
    /// </remarks>
    [HttpPost("register")]
    [ProducesResponseType(typeof(RegisterResultDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(void), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(void), StatusCodes.Status409Conflict)]
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

    /// <summary>
    /// Confirms the user's email address using a verification token.
    /// </summary>
    /// <remarks>
    /// Error keys:
    /// - **NOT_FOUND**: User or token not found.
    /// - **INCORRECT**: Invalid token.
    /// - **ALREADY_CONFIRMED**: Email is already verified.
    /// </remarks>
    [HttpPost("confirm-email")]
    [ProducesResponseType(typeof(ConfirmEmailResultDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(void), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(void), StatusCodes.Status404NotFound)]
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

    /// <summary>
    /// Resends the email confirmation link to the user.
    /// </summary>
    /// <remarks>
    /// Error keys:
    /// - **NOT_FOUND**: User not found.
    /// </remarks>
    [HttpPost("resend-confirm-email")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(void), StatusCodes.Status404NotFound)]
    public async Task<ActionResult> ResendConfirmEmail(ResendEmailConfirmationRequestModel request)
    {
        var result = await userService.ResendRegistrationEmailAsync(request.UserId);

        return !result.IsSuccess ? HandleErrors(result) : NoContent();
    }

    /// <summary>
    /// Authenticates a user and returns access tokens.
    /// </summary>
    /// <remarks>
    /// Error keys:
    /// - **INCORRECT_LOGIN_OR_PASSWORD**: Invalid credentials.
    /// - **NOT_FOUND**: User does not exist.
    /// </remarks>
    [HttpPost("login")]
    [ProducesResponseType(typeof(LoginResultDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(void), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(void), StatusCodes.Status404NotFound)]
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

    /// <summary>
    /// Authenticates a user using a Google ID token.
    /// </summary>
    /// <remarks>
    /// Error keys:
    /// - **BAD_REQUEST**: The Google token is invalid or expired.
    /// </remarks>
    [HttpPost("google-login")]
    [ProducesResponseType(typeof(LoginResultDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(void), StatusCodes.Status400BadRequest)]
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

    /// <summary>
    /// Retrieves profile information for a specific user.
    /// </summary>
    /// <remarks>
    /// Error keys:
    /// - **NOT_FOUND**: User not found.
    /// </remarks>
    [HttpGet("{userId}")]
    [ProducesResponseType(typeof(UserDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(void), StatusCodes.Status404NotFound)]
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
    
    /// <summary>
    /// Retrieves a list of all registered users.
    /// </summary>
    /// <remarks>
    /// Restricted to users with the Admin role.
    /// </remarks>
    [HttpGet]
    [Authorize(Roles = "Admin")]
    [ProducesResponseType(typeof(IEnumerable<UserAdminListItemDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<UserAdminListItemDto>>> GetAllUsers()
    {
        var result = await userService.GetAllUsersAsync();
        if (!result.IsSuccess)
        {
            return HandleErrors(result);
        }

        return Ok(result.Value);
    }
    
    /// <summary>
    /// Retrieves the global or language-specific leaderboard.
    /// </summary>
    /// <remarks>
    /// Error keys:
    /// - **NOT_FOUND**: Specified language not found.
    /// </remarks>
    [HttpGet("leaderboard")]
    [ProducesResponseType(typeof(IEnumerable<LeaderboardItemDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(void), StatusCodes.Status404NotFound)]
    public async Task<ActionResult<IEnumerable<LeaderboardItemDto>>> GetLeaderboard(Guid? languageId)
    {
        var result = await userService.GetLeaderboardAsync(languageId);
        
        if (!result.IsSuccess)
        {
            return HandleErrors(result);
        }

        return Ok(result.Value);
    }

    /// <summary>
    /// Bans a user from the application.
    /// </summary>
    /// <remarks>
    /// Restricted to users with the Admin role.
    /// Error keys:
    /// - **NOT_FOUND**: User not found.
    /// - **BAD_REQUEST**: Invalid ban parameters.
    /// </remarks>
    [HttpPost("{userId}/ban")]
    [Authorize(Roles = "Admin")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(void), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(void), StatusCodes.Status404NotFound)]
    public async Task<ActionResult> BanUser(Guid userId, BanUserRequestModel request)
    {
        var result = await userService.BanUserAsync(userId, mapper.Map<BanUserDto>(request));
        if (!result.IsSuccess)
        {
            return HandleErrors(result);
        }

        return NoContent();
    }

    /// <summary>
    /// Removes a ban from a user.
    /// </summary>
    /// <remarks>
    /// Restricted to users with the Admin role.
    /// Error keys:
    /// - **NOT_FOUND**: User not found.
    /// </remarks>
    [HttpPost("{userId}/unban")]
    [Authorize(Roles = "Admin")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(void), StatusCodes.Status404NotFound)]
    public async Task<ActionResult> UnbanUser(Guid userId)
    {
        var result = await userService.UnbanUserAsync(userId);
        if (!result.IsSuccess)
        {
            return HandleErrors(result);
        }

        return NoContent();
    }
    
    /// <summary>
    /// Updates the profile of the authorized user.
    /// </summary>
    /// <remarks>
    /// Allows updating the user's name and profile icon.
    /// Error keys:
    /// - **NOT_FOUND**: Authorized user profile not found.
    /// </remarks>
    [HttpPut]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(void), StatusCodes.Status404NotFound)]
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
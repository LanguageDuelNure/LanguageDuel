using AutoMapper;
using LanguageDuel.Application.Dtos.Results;
using LanguageDuel.Application.Dtos.Users;
using LanguageDuel.Application.Services;
using LanguageDuel.WebApi.Requests.Users;
using Microsoft.AspNetCore.Mvc;

namespace LanguageDuel.WebApi.Controllers;

[Route("api/[controller]")]
[ApiController]
public class UsersController(IUserService userService, IMapper mapper) : BaseController
{
    private readonly IUserService _userService = userService;
    private readonly IMapper _mapper = mapper;

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
        var result = await _userService.RegisterUserAsync(_mapper.Map<RegisterUserDto>(request));
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
        var result = await _userService.ConfirmEmailAsync(_mapper.Map<ConfirmEmailDto>(request));
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
    [ProducesResponseType(typeof(void), StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status404NotFound)]
    [ProducesResponseType(typeof(Result), StatusCodes.Status500InternalServerError)]
    public async Task<ActionResult> ResendConfirmEmail(ResendEmailConfirmationRequestModel request)
    {
        var result = await _userService.ResendRegistrationEmailAsync(request.UserId);

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
        var result = await _userService.LoginAsync(_mapper.Map<LoginUserDto>(request));

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
    public async Task<ActionResult<UserDto>> GetUser(string userId)
    {
        var result = await _userService.GetUserDtoAsync(userId);
        if (!result.IsSuccess)
        {
            return HandleErrors(result);
        }

        var userDto = result.Value;

        return Ok(userDto);
    }
}

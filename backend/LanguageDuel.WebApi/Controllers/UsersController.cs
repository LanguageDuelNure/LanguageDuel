using AutoMapper;
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

    [HttpPost("register")]
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

    [HttpPost("confirm-email")]
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

    [HttpPost("resend-confirm-email")]
    public async Task<ActionResult> ResendConfirmEmail(ResendEmailConfirmationRequestModel request)
    {
        var result = await _userService.ResendRegistrationEmailAsync(request.UserId);

        return !result.IsSuccess ? HandleErrors(result) : NoContent();
    }

    [HttpPost("login")]
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

    [HttpGet("{userId}")]
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

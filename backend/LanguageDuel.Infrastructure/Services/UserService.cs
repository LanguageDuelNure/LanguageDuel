using LanguageDuel.Application.Dtos.Results;
using LanguageDuel.Application.Dtos.Users;
using LanguageDuel.Application.Services;
using LanguageDuel.Domain;
using LanguageDuel.Infrastructure.Common;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.UI.Services;
using Microsoft.EntityFrameworkCore;

namespace LanguageDuel.Infrastructure.Services;

public class UserService(UserManager<ApplicationUser> userManager, SignInManager<ApplicationUser> signInManager, IEmailSender emailSender, ApplicationDbContext dbContext, IJwtTokenService jwtTokenService) : IUserService
{
    private readonly UserManager<ApplicationUser> _userManager = userManager;
    private readonly SignInManager<ApplicationUser> _signInManager = signInManager;
    private readonly IEmailSender _emailSender = emailSender;
    private readonly ApplicationDbContext _dbContext = dbContext;
    private readonly IJwtTokenService _jwtTokenService = jwtTokenService;

    public async Task<Result<RegisterResultDto>> RegisterUserAsync(RegisterUserDto dto)
    {
        string code = GenerateVerificationCode();
        var user = new ApplicationUser
        {
            UserName = dto.Email,
            Email = dto.Email,
            Name = dto.Name,
            VerificationCode = code
        };
        var result = await _userManager.CreateAsync(user, dto.Password);

        if (!result.Succeeded)
        {
            return result.Errors.Any(e => e.Code == "DuplicateUserName")
                ? new Result<RegisterResultDto>
                {
                    Errors =
                    [
                        new Error
                        {
                            Message = "User with this email already exists",
                            Field = "Email",
                            Key = ErrorKey.RepeatedValue,
                        }
                    ]
                }
                : new Result<RegisterResultDto>
                {
                    Errors =
                    [
                        new Error
                        {
                            Message = "Failed to register user",
                            Field = "Email",
                            Key = ErrorKey.UnexpectedError,
                        }
                    ]
                };
        }

        _ = await _userManager.AddToRoleAsync(user, DefaultRoles.UserRole.Name!);

        await SendRegistrationEmailAsync(user.Email!, user.VerificationCode!);

        return new Result<RegisterResultDto>
        {
            Value = new RegisterResultDto
            {
                UserId = user.Id
            }
        };
    }

    public async Task<Result> ResendRegistrationEmailAsync(string userId)
    {
        var getUserResult = await GetUserAsync(userId);
        if (!getUserResult.IsSuccess)
        {
            return new Result
            {
                Errors = getUserResult.Errors
            };
        }

        var user = getUserResult.Value;

        string code = GenerateVerificationCode();
        user.VerificationCode = code;
        _ = await _userManager.UpdateAsync(user);

        await SendRegistrationEmailAsync(user.Email!, code);

        return new Result();

    }

    public async Task<Result<ConfirmEmailResultDto>> ConfirmEmailAsync(ConfirmEmailDto dto)
    {
        var getUserResult = await GetUserAsync(dto.UserId);
        if (!getUserResult.IsSuccess)
        {
            return new Result<ConfirmEmailResultDto>
            {
                Errors = getUserResult.Errors
            };
        }

        var user = getUserResult.Value;

        if (user.EmailConfirmed)
        {
            return new Result<ConfirmEmailResultDto>
            {
                Errors =
                    [
                        new Error
                        {
                            Message = "Email already confirmed",
                            Field = "Email",
                            Key = ErrorKey.UnexpectedError,
                        }
                    ]
            };
        }

        if (user.VerificationCode != dto.Code)
        {
            return new Result<ConfirmEmailResultDto>
            {
                Errors =
                    [
                        new Error
                        {
                            Message = "Token incorrect",
                            Field = "Email",
                            Key = ErrorKey.Incorrect,
                        }
                    ]
            };
        }

        user.EmailConfirmed = true;
        _ = await _userManager.UpdateAsync(user);
        await _signInManager.SignInAsync(user, true);

        var role = (await _userManager.GetRolesAsync(user)).First();

        return new Result<ConfirmEmailResultDto>
        {
            Value = new ConfirmEmailResultDto
            {
                Role = role,
                JwtToken = _jwtTokenService.GenerateToken(user.Id, role)
            }
        };
    }

    public async Task<Result<LoginResultDto>> LoginAsync(LoginUserDto dto)
    {
        var user = await _userManager.FindByEmailAsync(dto.Email);
        if (user == null)
        {
            return new Result<LoginResultDto>
            {
                Errors =
                [
                    GetUserNotFoundError()
                ]
            };
        }
        var result = await _signInManager.PasswordSignInAsync(user, dto.Password, true, false);
        bool emailConfirmed = true;
        if (!result.Succeeded)
        {
            if (user.EmailConfirmed)
            {
                return new Result<LoginResultDto>
                {
                    Errors =
                    [
                        new Error
                        {
                            Message = "Login or password incorrect",
                            Field = string.Empty,
                            Key = ErrorKey.IncorrectLoginOrPassword,
                        }
                    ]
                };
            }

            string code = GenerateVerificationCode();
            user.VerificationCode = code;
            _ = await _userManager.UpdateAsync(user);

            await SendRegistrationEmailAsync(dto.Email, code);

            emailConfirmed = false;
        }

        var role = (await _userManager.GetRolesAsync(user)).First();

        return new Result<LoginResultDto>
        {
            Value = new LoginResultDto
            {
                UserId = user.Id,
                EmailConfirmed = emailConfirmed,
                Role = role,
                JwtToken = emailConfirmed ? _jwtTokenService.GenerateToken(user.Id, role) : null
            }
        };
    }

    public async Task<Result<UserDto>> GetUserDtoAsync(string userId)
    {
        var user = await _dbContext.Users
            .Where(u => u.Id == userId)
            .Select(u => new UserDto
            {
                Id = u.Id,
                Name = u.Name
            })
            .FirstOrDefaultAsync();
        return user == null
            ? new Result<UserDto>
            {
                Errors =
                [
                    new Error
                    {
                        Message = "User not found",
                        Field = string.Empty,
                        Key = ErrorKey.NotFound,
                    }
                ]
            }
            : new Result<UserDto>
            {
                Value = user
            };
    }

    private async Task<Result<ApplicationUser>> GetUserAsync(string userId)
    {
        var user = await _userManager.FindByIdAsync(userId);
        return user == null
            ? new Result<ApplicationUser>
            {
                Errors =
                [
                    GetUserNotFoundError()
                ]
            }
            : new Result<ApplicationUser>
            {
                Value = user
            };
    }

    private static Error GetUserNotFoundError()
    {
        return new Error
        {
            Message = "User not found",
            Field = string.Empty,
            Key = ErrorKey.NotFound,
        };
    }

    private static string GenerateVerificationCode()
    {
        Random random = new();
        return random.Next(1000000).ToString("D6");
    }

    private async Task SendRegistrationEmailAsync(string email, string code)
    {
        await _emailSender.SendEmailAsync(
            email,
            "Registration confirmation",
            $"Confirm email to register in LanguageDuel. Confirmation code: {code}");
    }
}

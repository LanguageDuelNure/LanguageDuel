using AutoMapper;
using LanguageDuel.Application.Dtos.Results;
using LanguageDuel.Application.Dtos.UserLanguages;
using LanguageDuel.Application.Dtos.Users;
using LanguageDuel.Application.Services;
using LanguageDuel.Domain;
using LanguageDuel.Domain.Common;
using LanguageDuel.Domain.Entities;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.UI.Services;
using Microsoft.EntityFrameworkCore;

namespace LanguageDuel.Infrastructure.Services;

public class UserService(UserManager<ApplicationUser> userManager, SignInManager<ApplicationUser> signInManager, IEmailSender emailSender, ApplicationDbContext dbContext, IJwtTokenService jwtTokenService, IMapper mapper) : IUserService
{
    private const int UserOpponentCount = 10;
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
        var result = await userManager.CreateAsync(user, dto.Password);

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
                            Key = ErrorKey.AlreadyExists,
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

        _ = await userManager.AddToRoleAsync(user, DefaultRoles.UserRole.Name!);

        await SendRegistrationEmailAsync(user.Email!, user.VerificationCode!);

        return new Result<RegisterResultDto>
        {
            Value = new RegisterResultDto
            {
                UserId = user.Id
            }
        };
    }

    public async Task<Result> ResendRegistrationEmailAsync(Guid userId)
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
                            Key = ErrorKey.AlreadyConfirmed,
                        }
                    ]
            };
        }

        string code = GenerateVerificationCode();
        user.VerificationCode = code;
        _ = await userManager.UpdateAsync(user);

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
                            Key = ErrorKey.AlreadyConfirmed,
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
        _ = await userManager.UpdateAsync(user);
        await signInManager.SignInAsync(user, true);

        var role = (await userManager.GetRolesAsync(user)).First();

        return new Result<ConfirmEmailResultDto>
        {
            Value = new ConfirmEmailResultDto
            {
                Role = role,
                JwtToken = jwtTokenService.GenerateToken(user.Id, role)
            }
        };
    }

    public async Task<Result<LoginResultDto>> LoginAsync(LoginUserDto dto)
    {
        var user = await userManager.FindByEmailAsync(dto.Email);
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
        var result = await signInManager.PasswordSignInAsync(user, dto.Password, true, false);
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
            _ = await userManager.UpdateAsync(user);

            await SendRegistrationEmailAsync(dto.Email, code);

            emailConfirmed = false;
        }

        var role = (await userManager.GetRolesAsync(user)).First();

        return new Result<LoginResultDto>
        {
            Value = new LoginResultDto
            {
                UserId = user.Id,
                EmailConfirmed = emailConfirmed,
                Role = role,
                JwtToken = emailConfirmed ? jwtTokenService.GenerateToken(user.Id, role) : null
            }
        };
    }

    public async Task<Result<UserDto>> GetUserDtoAsync(Guid userId)
    {
        var user = await dbContext.Users
            .Where(u => u.Id == userId)
            .Include(u => u.ApplicationUserLanguages)
            .Include(u => u.ApplicationUserOpponents)
            .ThenInclude(uo => uo.Opponent)
            .Include(u => u.OpponentApplicationUsers)
            .ThenInclude(uo => uo.ApplicationUser)
            .FirstOrDefaultAsync();

        if (user == null)
        {
            return new Result<UserDto>
            {
                Errors = [new Error { Message = "User not found", Key = ErrorKey.NotFound }]
            };
        }
        
        var userDto = mapper.Map<UserDto>(user);
        
        var opponentsFromInitiator = user.ApplicationUserOpponents
            .Select(uo => new UserOpponentDto
            {
                LastPlayedAt = uo.LastPlayedAt,
                MatchesPlayed = uo.MatchesPlayed,
                UserId = uo.OpponentId,
                Name = uo.Opponent.Name
            });

        var opponentsFromTarget = user.OpponentApplicationUsers
            .Select(uo => new UserOpponentDto
            {
                LastPlayedAt = uo.LastPlayedAt,
                MatchesPlayed = uo.MatchesPlayed,
                UserId = uo.ApplicationUserId,
                Name = uo.ApplicationUser.Name
            });

        userDto.UserOpponents = opponentsFromInitiator
            .Concat(opponentsFromTarget)
            .OrderByDescending(uo => uo.MatchesPlayed)
            .Take(UserOpponentCount)
            .ToList();
    
        return new Result<UserDto> { Value = userDto };
    }

    public async Task<Result> UpdateUserStatisticAsync(Guid userId, bool isWin)
    {
        var getUserResult = await GetUserAsync(userId);
        if (!getUserResult.IsSuccess)
        {
            return new Result<UserDto>
            {
                Errors = getUserResult.Errors
            };
        }

        var user = getUserResult.Value;

        user.TotalGames++;
        if (isWin)
        {
            user.TotalWins++;
        }
        
        return new Result();
    }

    private async Task<Result<ApplicationUser>> GetUserAsync(Guid userId)
    {
        var user = await userManager.FindByIdAsync(userId.ToString());
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
        await emailSender.SendEmailAsync(
            email,
            "Registration confirmation",
            $"Confirm email to register in LanguageDuel. Confirmation code: {code}");
    }
}

using LanguageDuel.Application.Dtos.Results;
using LanguageDuel.Application.Dtos.Users;

namespace LanguageDuel.Application.Services;

public interface IUserService
{
    Task<Result<ConfirmEmailResultDto>> ConfirmEmailAsync(ConfirmEmailDto dto);
    Task<Result<UserDto>> GetUserDtoAsync(Guid userId);
    Task<Result<LoginResultDto>> LoginAsync(LoginUserDto dto);
    Task<Result<RegisterResultDto>> RegisterUserAsync(RegisterUserDto dto);
    Task<Result> ResendRegistrationEmailAsync(Guid userId);
    Task<Result<RatingRangeDto>> GetRatingRangeAsync(Guid userId);
}
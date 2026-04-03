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
    Task<Result> UpdateUserStatisticAsync(Guid userId, bool isWin);
    Task<Result<LoginResultDto>> HandleGoogleLoginAsync(string idToken);
    Task<Result> UpdateUserProfileAsync(Guid userId, UpdateUserProfileDto dto);
    Task<Result<IEnumerable<UserAdminListItemDto>>> GetAllUsersAsync();
    Task<Result> BanUserAsync(Guid userId, int days);
    Task<Result> UnbanUserAsync(Guid userId);
    Task<Result<IEnumerable<LeaderboardItemDto>>> GetLeaderboardAsync(Guid? languageId);
}
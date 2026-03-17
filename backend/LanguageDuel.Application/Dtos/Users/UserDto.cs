using LanguageDuel.Application.Dtos.UserLanguages;

namespace LanguageDuel.Application.Dtos.Users;

public class UserDto
{
    public Guid Id { get; set; }

    public string Name { get; set; } = string.Empty;
    
    public List<UserLanguageDto> LanguageRatings { get; set; }
}

namespace LanguageDuel.Application.Dtos.Users;

public class UpdateUserProfileDto
{
    public string Name { get; set; }
    
    public Stream? Icon { get; set; }
    
    public string? IconName { get; set; }
}
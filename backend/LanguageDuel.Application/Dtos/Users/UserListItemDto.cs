namespace LanguageDuel.Application.Dtos.Users;

public class UserListItemDto
{
    public Guid Id { get; set; }

    public string Name { get; set; } = string.Empty;
    
    public string Email { get; set; } = string.Empty;
    
    public bool EmailConfirmed { get; set; }
    
    public string Role { get; set; } = string.Empty;
    
    public TimeSpan? RemainingBanDuration { get; set; }
    
    public string? ImageUrl { get; set; }
}
namespace LanguageDuel.Application.Dtos.Users;

public class UserAdminListItemDto
{
    public Guid Id { get; set; }

    public string Name { get; set; } = string.Empty;
    
    public string Email { get; set; } = string.Empty;
    
    public bool EmailConfirmed { get; set; }
    
    public string Role { get; set; } = string.Empty;
    
    public bool IsBanned { get; set; }
    public DateTime? BannedUntil { get; set; }
    
    public string? ImageUrl { get; set; }
}
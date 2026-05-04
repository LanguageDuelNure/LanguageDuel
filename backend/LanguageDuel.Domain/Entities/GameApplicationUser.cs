namespace LanguageDuel.Domain.Entities;

public class GameApplicationUser
{
    public Guid GameId { get; set; }
    
    public Game Game { get; set; }
    
    public Guid ApplicationUserId { get; set; }
    
    public ApplicationUser ApplicationUser { get; set; }
    
    public bool IsWin { get; set; }
}
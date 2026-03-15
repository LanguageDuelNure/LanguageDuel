namespace LanguageDuel.Application.Dtos.Games;

public class UserInGameDto
{
    public Guid Id { get; set; }

    public string Name { get; set; } = string.Empty;
    
    public int Hp { get; set; }
}
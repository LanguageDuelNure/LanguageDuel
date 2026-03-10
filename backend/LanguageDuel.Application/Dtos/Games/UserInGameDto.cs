namespace LanguageDuel.Application.Dtos.Games;

public class UserInGameDto
{
    public string Id { get; set; } = string.Empty;

    public string Name { get; set; } = string.Empty;
    
    public int Hp { get; set; } = 10;
}
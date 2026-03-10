namespace LanguageDuel.Application.Dtos.Games;

public class GameSessionDto
{
    public Guid Id { get; set; }

    public List<QuestionDto> Questions { get; set; } = [];
}
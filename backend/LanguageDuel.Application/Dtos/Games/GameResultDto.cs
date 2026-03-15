using LanguageDuel.Application.Dtos.Questions;

namespace LanguageDuel.Application.Dtos.Games;

public class GameResultDto
{
    public string? WinnerUserName { get; set; }
    
    public List<QuestionDto> Questions { get; set; }
}
using LanguageDuel.Application.Dtos.Answers;
using LanguageDuel.Application.Dtos.Questions;

namespace LanguageDuel.Application.Dtos.Games;

public class GameStateDto
{
    public QuestionDto CurrentQuestion { get; set; } = null!;
}
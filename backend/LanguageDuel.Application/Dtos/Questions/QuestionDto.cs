using LanguageDuel.Application.Dtos.Answers;

namespace LanguageDuel.Application.Dtos.Questions;

public class QuestionDto
{
    public Guid Id { get; set; }

    public string Name { get; set; } = string.Empty;

    public IEnumerable<AnswerDto> Answers { get; set; } = [];

    public Dictionary<Guid, Guid> UserAnswers { get; set; } = [];
}
namespace LanguageDuel.Application.Dtos.Answers;

public class AnswerDto
{
    public Guid Id { get; set; }

    public string Name { get; set; } = string.Empty;

    public bool IsCorrect { get; set; }
}
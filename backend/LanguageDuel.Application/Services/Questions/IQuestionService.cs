using LanguageDuel.Application.Dtos.Questions;
using LanguageDuel.Application.Dtos.Results;

namespace LanguageDuel.Application.Services.Questions;

public interface IQuestionService
{
    Task<Result<IEnumerable<QuestionDto>>> GetRandomQuestionsAsync(Guid languageId, Guid difficultyLevelId, int questionCount);
}
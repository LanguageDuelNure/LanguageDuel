using LanguageDuel.Domain;
using LanguageDuel.Domain.Entities;

namespace LanguageDuel.Application.Repositories;

public interface IQuestionRepository
{
    Task<IEnumerable<Question>> GetRandomQuestionsAsync(Guid languageId, Guid difficultyLevelId, int questionCount);
}
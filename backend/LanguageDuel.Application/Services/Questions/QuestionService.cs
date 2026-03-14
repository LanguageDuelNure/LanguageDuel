using AutoMapper;
using LanguageDuel.Application.Dtos.Questions;
using LanguageDuel.Application.Dtos.Results;
using LanguageDuel.Application.Repositories;
using LanguageDuel.Domain;
using LanguageDuel.Domain.Entities;

namespace LanguageDuel.Application.Services.Questions;

public class QuestionService(IQuestionRepository questionRep, IMapper mapper) : IQuestionService
{
    public async Task<Result<IEnumerable<QuestionDto>>> GetRandomQuestionsAsync(Guid languageId, Guid difficultyLevelId, int questionCount)
    {
        var questions = await questionRep.GetRandomQuestionsAsync(languageId, difficultyLevelId, questionCount);
        
        return new Result<IEnumerable<QuestionDto>>()
        {
            Value = mapper.Map<IEnumerable<QuestionDto>>(questions)
        };
    }
}
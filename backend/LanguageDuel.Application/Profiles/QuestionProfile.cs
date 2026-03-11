using AutoMapper;
using LanguageDuel.Application.Dtos.Questions;
using LanguageDuel.Domain;

namespace LanguageDuel.Application.Profiles;

public class QuestionProfile : Profile
{
    public QuestionProfile()
    {
        CreateMap<Question, QuestionDto>();
    }
}
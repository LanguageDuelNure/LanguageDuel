using AutoMapper;
using LanguageDuel.Application.Dtos.Answers;
using LanguageDuel.Domain.Entities;

namespace LanguageDuel.Application.Profiles;

public class AnswerProfile : Profile
{
    public AnswerProfile()
    {
        CreateMap<Answer, AnswerDto>();
        CreateMap<AnswerDto, GameStateAnswerDto>();
    }
}
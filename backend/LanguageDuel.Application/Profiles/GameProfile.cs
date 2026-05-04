using AutoMapper;
using LanguageDuel.Application.Dtos.Answers;
using LanguageDuel.Application.Dtos.Games;
using LanguageDuel.Application.Dtos.Questions;
using LanguageDuel.Domain.Entities;

namespace LanguageDuel.Application.Profiles;

public class GameProfile : Profile
{
    public GameProfile()
    {
        CreateMap<GameSessionDto, Game>()
            .ForMember(dest => dest.GameApplicationUsers, opt => opt.MapFrom(src => src.Users))
            .ForMember(dest => dest.GameQuestions, opt => opt.MapFrom(src => src.Questions));
        
        CreateMap<GameSessionUserDto, GameApplicationUser>()
            .ForMember(dest => dest.ApplicationUserId, opt => opt.MapFrom(src => src.Id));
        
        CreateMap<QuestionDto, GameQuestion>()
            .ForMember(dest => dest.QuestionId, opt => opt.MapFrom(src => src.Id))
            .ForMember(dest => dest.GameAnswers, opt => opt.MapFrom(src => src.Answers));

        CreateMap<AnswerDto, GameAnswer>()
            .ForMember(dest => dest.AnswerId, opt => opt.MapFrom(src => src.Id));

        CreateMap<Game, GameResultDto>()
            .ForMember(dest => dest.DifficultyLevelName, opt => opt.MapFrom(src => src.DifficultyLevel.Name))
            .ForMember(dest => dest.LanguageName, opt => opt.MapFrom(src => src.Language.Name))
            .ForMember(dest => dest.Questions, opt => opt.MapFrom(src => src.GameQuestions));
        
        CreateMap<Game, GameResultListItemDto>()
            .ForMember(dest => dest.DifficultyLevelName, opt => opt.MapFrom(src => src.DifficultyLevel.Name))
            .ForMember(dest => dest.LanguageName, opt => opt.MapFrom(src => src.Language.Name));

        CreateMap<GameQuestion, QuestionDto>()
            .ForMember(dest => dest.Name, opt => opt.MapFrom(src => src.Question.Name));
        
        CreateMap<GameAnswer, AnswerDto>()
            .ForMember(dest => dest.Name, opt => opt.MapFrom(src => src.Answer.Name));
    }
}
using AutoMapper;
using LanguageDuel.Application.Dtos.DifficultyLevels;
using LanguageDuel.Domain.Entities;

namespace LanguageDuel.Application.Profiles;

public class DifficultyLevelProfile : Profile
{
    public  DifficultyLevelProfile()
    {
        CreateMap<DifficultyLevel, DifficultyLevelDto>();
    }
}
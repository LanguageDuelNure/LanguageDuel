using LanguageDuel.Domain;
using LanguageDuel.Domain.Entities;

namespace LanguageDuel.Infrastructure.Common;

public class DefaultDifficultyLevels
{
    public static readonly DifficultyLevel EasyDifficulty = new()
    {
        Id =  new Guid("fa9a4d67-89b0-4837-84da-e43268302def"),
        Name = "Easy",
    };

    public static readonly DifficultyLevel MediumDifficulty = new()
    {
        Id =  new Guid("57d4c26a-2fe4-45c5-99fe-41907a9cfeb7"),
        Name = "Medium",
    };
    
    public static readonly DifficultyLevel HardDifficulty = new()
    {
        Id =  new Guid("1cd354c5-ae2d-4ea0-baad-5742dae6162f"),
        Name = "Hard",
    };
    
    public static readonly DifficultyLevel VeryHardDifficulty = new()
    {
        Id =  new Guid("70fbf803-119f-4be1-a6b5-4da306b4828f"),
        Name = "Very Hard",
    };
}
using LanguageDuel.Domain.Entities;

namespace LanguageDuel.Domain.Common;

public abstract class DefaultDifficultyLevels
{
    public static readonly DifficultyLevel EasyDifficulty = new()
    {
        Id =  new Guid("fa9a4d67-89b0-4837-84da-e43268302def"),
        Name = "Easy",
        StartRating = 0,
    };

    public static readonly DifficultyLevel MediumDifficulty = new()
    {
        Id =  new Guid("57d4c26a-2fe4-45c5-99fe-41907a9cfeb7"),
        Name = "Medium",
        StartRating = 30,
    };
    
    public static readonly DifficultyLevel HardDifficulty = new()
    {
        Id =  new Guid("1cd354c5-ae2d-4ea0-baad-5742dae6162f"),
        Name = "Hard",
        StartRating = 70,
    };
    
    public static readonly DifficultyLevel VeryHardDifficulty = new()
    {
        Id =  new Guid("70fbf803-119f-4be1-a6b5-4da306b4828f"),
        Name = "Very Hard",
        StartRating = 120,
    };
}
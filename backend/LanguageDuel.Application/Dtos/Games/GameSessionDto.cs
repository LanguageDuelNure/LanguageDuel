using LanguageDuel.Application.Dtos.Questions;
using Timer = System.Timers.Timer;

namespace LanguageDuel.Application.Dtos.Games;

public class GameSessionDto
{
    public Guid Id { get; set; }

    public Guid LanguageId { get; set; }
    
    public Guid DifficultyLevelId { get; set; }

    public string LanguageName { get; set; } = string.Empty;

    public List<QuestionDto> Questions { get; set; } = [];

    public int CurrentQuestionIndex { get; set; }

    public List<GameSessionUserDto> Users { get; set; } = [];

    public Timer Timer { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime CurrentQuestionStartDateTime { get; set; }
}
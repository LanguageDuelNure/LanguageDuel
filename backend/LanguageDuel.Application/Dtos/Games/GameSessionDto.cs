using LanguageDuel.Application.Dtos.Questions;
using LanguageDuel.Application.Dtos.Users;
using Timer = System.Timers.Timer;

namespace LanguageDuel.Application.Dtos.Games;

public class GameSessionDto
{
    public Guid Id { get; set; }

    public List<QuestionDto> Questions { get; set; } = [];
    
    public int CurrentQuestionIndex { get; set; }
    
    public List<GameSessionUserDto> Users { get; set; } = [];
    
    public Timer Timer { get; set; }
}
using LanguageDuel.Application.Dtos.Questions;

namespace LanguageDuel.Application.Dtos.Games;

public class GameResultDto
{
    public Guid? WinnerUserId { get; set; }

    public string? WinnerUserName { get; set; }

    public bool IsGiveUp { get; set; }

    public int RatingChangeAfterWinOrLoss { get; set; }

    public List<QuestionDto> Questions { get; set; }
}
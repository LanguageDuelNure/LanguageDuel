namespace LanguageDuel.Application.Options;

public class GameLogicOptions
{
    public int QuestionsCount { get; set; }

    public int RatingChangeAfterWinOrLoss { get; set; }

    public int TimeForQuestionInSeconds { get; set; }

    public int RatingRange { get; set; }

    public int QuestionDelayMs { get; set; }
}
namespace LanguageDuel.Domain.Entities;

public class GameQuestion
{
    public Guid Id { get; set; }
    public Guid GameId { get; set; }
    public Game Game { get; set; }
    public Guid QuestionId { get; set; }
    public Question Question { get; set; }
    public ICollection<GameAnswer> GameAnswers { get; set; }
}
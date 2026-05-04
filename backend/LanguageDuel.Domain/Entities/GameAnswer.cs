namespace LanguageDuel.Domain.Entities;

public class GameAnswer
{
    public Guid GameQuestionId { get; set; }
    
    public GameQuestion GameQuestion { get; set; }
    
    public Guid AnswerId { get; set; }
    
    public Answer Answer { get; set; }
    
    public Guid? ApplicationUserId { get; set; }
    
    public ApplicationUser? ApplicationUser { get; set; }
}
namespace LanguageDuel.Application.Dtos.Tickets;

public class TicketMessageDto
{
    public Guid Id { get; set; }
    
    public string Message { get; set; }
    
    public string CreatedAt { get; set; }
    
    public bool IsMine { get; set; }
    
    public Guid UserId { get; set; }
}
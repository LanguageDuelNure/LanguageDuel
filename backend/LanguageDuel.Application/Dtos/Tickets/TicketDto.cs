namespace LanguageDuel.Application.Dtos.Tickets;

public class TicketDto
{
    public Guid Id { get; set; }
    
    public string UserName { get; set; }
    
    public string Status { get; set; }
    
    public string CreatedAt { get; set; }
    
    public Guid UserId { get; set; }
    
    public List<TicketMessageDto> Messages { get; set; } = new();
}
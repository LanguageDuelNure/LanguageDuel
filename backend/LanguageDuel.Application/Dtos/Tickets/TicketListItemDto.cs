namespace LanguageDuel.Application.Dtos.Tickets;

public class TicketListItemDto
{
    public Guid Id { get; set; }
    
    public Guid UserId { get; set; }
    
    public string UserName { get; set; }
    
    public string LastMessage { get; set; }
    
    public string Status { get; set; }
    
    public string CreatedAt { get; set; }
}
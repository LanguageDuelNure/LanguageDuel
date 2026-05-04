namespace LanguageDuel.WebApi.Requests.Tickets;

public class ReplyToTicketRequestModel
{
    public Guid TicketId { get; set; }
    
    public string Message { get; set; } = string.Empty;
}
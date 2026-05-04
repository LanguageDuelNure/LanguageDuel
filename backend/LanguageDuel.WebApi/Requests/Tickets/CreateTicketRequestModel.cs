namespace LanguageDuel.WebApi.Requests.Tickets;

public class CreateTicketRequestModel
{
    public Guid? TicketId { get; set; }
    
    public string Message { get; set; }
}
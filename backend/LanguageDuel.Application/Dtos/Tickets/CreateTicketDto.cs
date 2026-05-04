namespace LanguageDuel.Application.Dtos.Users;

public class CreateTicketDto
{
    public Guid? TicketId { get; set; }
    public string Message { get; set; }
}
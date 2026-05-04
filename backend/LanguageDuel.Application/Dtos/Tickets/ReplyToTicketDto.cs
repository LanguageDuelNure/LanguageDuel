namespace LanguageDuel.Application.Dtos.Tickets;

public class ReplyToTicketDto
{
    public Guid TicketId { get; set; }

    public string Message { get; set; } = string.Empty;
}
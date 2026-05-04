namespace LanguageDuel.Domain.Entities;

public class Ticket
{
    public Guid Id { get; set; }
    public Guid ApplicationUserId { get; set; }
    public ApplicationUser ApplicationUser { get; set; }
    public TicketStatus Status { get; set; } = TicketStatus.Open;

    public ICollection<TicketMessage> Messages { get; set; } = new List<TicketMessage>();
}
namespace LanguageDuel.Domain.Entities;

public class TicketMessage
{
    public Guid Id { get; set; }
    public Guid TicketId { get; set; }
    public Ticket Ticket { get; set; }
    public string Message { get; set; } = null!;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public Guid ApplicationUserId { get; set; }
    public ApplicationUser ApplicationUser { get; set; }
}
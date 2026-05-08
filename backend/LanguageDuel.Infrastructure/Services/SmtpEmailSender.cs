using LanguageDuel.Infrastructure.Options;
using MailKit.Net.Smtp;
using Microsoft.AspNetCore.Identity.UI.Services;
using Microsoft.Extensions.Options;
using MimeKit;

namespace LanguageDuel.Infrastructure.Services;

public class SmtpEmailSender(IOptions<SmtpEmailOptions> options) : IEmailSender
{
    private const string SenderName = "LanguageDuel";
    
    private readonly SmtpEmailOptions _options = options.Value;

    public async Task SendEmailAsync(string email, string subject, string htmlMessage)
    {
        var message = new MimeMessage();

        message.From.Add(new MailboxAddress(SenderName, _options.Email));

        message.To.Add(new MailboxAddress(string.Empty, email));

        message.Subject = subject;

        message.Body = new TextPart("html")
        {
            Text = htmlMessage
        };

        using var smtp = new SmtpClient();
        await smtp.ConnectAsync(_options.Host, _options.Port, MailKit.Security.SecureSocketOptions.StartTls);
        await smtp.AuthenticateAsync(_options.Email, _options.Password);
        await smtp.SendAsync(message);
        await smtp.DisconnectAsync(true);
    }
}

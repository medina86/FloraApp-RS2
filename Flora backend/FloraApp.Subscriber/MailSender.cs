using FloraApp.Subscriber;
using MailKit.Net.Smtp;
using MailKit.Security;
using MimeKit;
using System;
using System.Threading.Tasks;

public static class MailSender
{
    private static SmtpSettings? _smtpSettings;

    public static void Initialize(SmtpSettings smtpSettings)
    {
        _smtpSettings = smtpSettings;
    }

    public static async Task<bool> SendEmail(Flora.Models.EmailMessage mailObj)
    {
        if (_smtpSettings == null)
        {
            Console.WriteLine("SMTP settings nisu inicijalizirane!");
            return false;
        }

        if (mailObj == null) return false;

        var email = new MimeMessage();
        email.From.Add(new MailboxAddress(_smtpSettings.DisplayName, _smtpSettings.Username));
        email.To.Add(new MailboxAddress(mailObj.To ?? mailObj.To, mailObj.To));
        email.Subject = mailObj.Subject ?? "";
        email.Body = new TextPart(MimeKit.Text.TextFormat.Html)
        {
            Text = mailObj.Body ?? ""
        };

        try
        {
            using var smtp = new SmtpClient();

            SecureSocketOptions socketOptions = _smtpSettings.Port switch
            {
                465 => SecureSocketOptions.SslOnConnect,
                587 => SecureSocketOptions.StartTls,
                _ => _smtpSettings.EnableSSL ? SecureSocketOptions.SslOnConnect : SecureSocketOptions.Auto
            };

            await smtp.ConnectAsync(_smtpSettings.Host, _smtpSettings.Port, socketOptions);
            await smtp.AuthenticateAsync(_smtpSettings.Username, _smtpSettings.Password);
            await smtp.SendAsync(email);
            await smtp.DisconnectAsync(true);

            Console.WriteLine($"Email poslan na {mailObj.To}");
            return true;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Greška pri slanju mejla: {ex.Message}");
            return false;
        }
    }
}

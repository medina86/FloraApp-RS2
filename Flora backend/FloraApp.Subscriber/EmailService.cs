using Flora.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Mail;
using System.Text;
using System.Threading.Tasks;

namespace FloraApp.Subscriber
{
    public class EmailService
    {
        
        public async Task<bool> SendEmail(EmailMessage email)
        {
            if (email == null)
            {
                Console.WriteLine("Email payload is null");
                return false;
            }

            if (string.IsNullOrWhiteSpace(email.To))
            {
                Console.WriteLine("Recipient email is empty");
                return false;
            }

            return await MailSender.SendEmail(email);
        }
    }
    public class SmtpSettings
    {
        public string Username { get; set; } = "";
        public string Password { get; set; } = "";
        public string Host { get; set; } = "smtp.gmail.com";
        public int Port { get; set; } = 587;
        public bool EnableSSL { get; set; } = true;
        public string DisplayName { get; set; } = "Flora App";
    }

    public class RabbitMQSettings
    {
        public string HostName { get; set; } = "localhost";
        public string UserName { get; set; } = "guest";
        public string Password { get; set; } = "guest";
        public int Port { get; set; } = 5672;
        public string ExchangeName { get; set; } = "EmailExchange";
        public string RoutingKey { get; set; } = "order_notifications";
        public string QueueName { get; set; } = "email_notifications_q";
    }

}

using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System.Text;
using Newtonsoft.Json;
using FloraApp.Subscriber;

Console.WriteLine("Starting  Email Subscriber...");
Console.WriteLine("Sleeping to wait for Rabbit...");
await Task.Delay(11000);
Console.WriteLine("Consuming Queue Now");

string GetEnv(string defaultValue, params string[] keys)
{
    foreach (var k in keys)
    {
        var v = Environment.GetEnvironmentVariable(k);
        if (!string.IsNullOrWhiteSpace(v)) return v;
    }
    return defaultValue;
}

int GetEnvInt(int defaultValue, params string[] keys)
{
    var s = GetEnv(string.Empty, keys);
    return int.TryParse(s, out var i) ? i : defaultValue;
}

IConnection? connection = null;
IModel? channel = null;

try
{
    try
    {
        DotNetEnv.Env.TraversePath().Load();
        Console.WriteLine("Loaded environment from .env");
    }
    catch
    {
        Console.WriteLine("No .env file loaded.");
    }

    var hostname = GetEnv("localhost", "_rabbitMqHost", "RABBITMQ_HOST");
    var username = GetEnv("guest", "_rabbitMqUser", "RABBITMQ_USERNAME");
    var password = GetEnv("guest", "_rabbitMqPassword", "RABBITMQ_PASSWORD");
    var port = GetEnvInt(5672, "_rabbitMqPort", "RABBITMQ_PORT");

    var factory = new ConnectionFactory()
    {
        HostName = hostname,
        Port = port,
        UserName = username,
        Password = password
    };

    Console.WriteLine($"Connecting to RabbitMQ at {hostname}:{port} with user {username}");

    var smtpSettings = new SmtpSettings
    {
        Username = GetEnv("your_email@gmail.com", "SMTP_USERNAME"),
        Password = GetEnv("your_app_password", "SMTP_PASSWORD"),
        Host = GetEnv("smtp.gmail.com", "SMTP_HOST"),
        Port = GetEnvInt(587, "SMTP_PORT"),
        EnableSSL = true,
        DisplayName = "Flora App"
    };
    
    MailSender.Initialize(smtpSettings);
    Console.WriteLine("SMTP settings initialized");

    factory.ClientProvidedName = "Flora Email Consumer";
    connection = factory.CreateConnection();
    channel = connection.CreateModel();

    string exchangeName = "EmailExchange";
    string queueName = GetEnv("email_notifications_q", "MAIL_QUEUE_NAME");

    channel.ExchangeDeclare(exchangeName, ExchangeType.Direct, durable: true, autoDelete: false);
    channel.QueueDeclare(queueName, durable: true, exclusive: false, autoDelete: false);
    
    channel.QueueBind(queueName, exchangeName, "order.created");
    channel.QueueBind(queueName, exchangeName, "order.statuschanged");
    Console.WriteLine("Queue bound to routing keys: order.created, order.statuschanged");

    channel.BasicQos(0, 5, false);

    var consumer = new EventingBasicConsumer(channel);

    consumer.Received += async (model, ea) =>
    {
        Console.WriteLine($"Message received! Routing key: {ea.RoutingKey}");
        var body = ea.Body.ToArray();
        var message = Encoding.UTF8.GetString(body);
        Console.WriteLine($"Message content: {message}");

        var maxAttempts = 3;
        var attempt = 0;
        var backoffMs = 1000;
        bool success = false;

        try
        {
            var entity = JsonConvert.DeserializeObject<Flora.Models.EmailMessage>(message);
            if (entity == null)
            {
                Console.WriteLine("Invalid message payload. Nacking without requeue.");
                channel.BasicNack(ea.DeliveryTag, multiple: false, requeue: false);
                return;
            }

            Console.WriteLine($"Processing email for Order #{entity.OrderId} to {entity.To} - Status: {entity.OrderState}");

            while (attempt < maxAttempts && !success)
            {
                attempt++;
                success = await MailSender.SendEmail(entity);
                if (!success)
                {
                    Console.WriteLine($"Send failed (attempt {attempt}/{maxAttempts}). Backing off {backoffMs}ms...");
                    await Task.Delay(backoffMs);
                    backoffMs *= 2;
                }
            }

            if (success)
            {
                Console.WriteLine($"Email successfully sent for Order #{entity.OrderId}");
                channel.BasicAck(ea.DeliveryTag, multiple: false);
            }
            else
            {
                Console.WriteLine("Max attempts reached. Nacking without requeue.");
                channel.BasicNack(ea.DeliveryTag, multiple: false, requeue: false);
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"ERROR processing message: {ex.Message}");
            channel.BasicNack(ea.DeliveryTag, multiple: false, requeue: false);
        }
    };

    channel.BasicConsume(queue: queueName, autoAck: false, consumer: consumer);

    Console.WriteLine("[*] Waiting for order notification messages.");
    
    Thread.Sleep(Timeout.Infinite);
}
catch (Exception ex)
{
    Console.WriteLine($"ERROR: {ex.Message}");
    if (ex.InnerException != null)
    {
        Console.WriteLine($"Inner exception: {ex.InnerException.Message}");
    }
    Console.WriteLine("Press [enter] to exit...");
    Console.ReadLine();
}
finally
{
    channel?.Close();
    connection?.Close();
}

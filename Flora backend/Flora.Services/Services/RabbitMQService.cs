using Flora.Services.Interfaces;
using RabbitMQ.Client.Exceptions;
using RabbitMQ.Client;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Text.Json;
using Microsoft.Extensions.Logging;


namespace Flora.Services.Services
{
    public class RabbitMQService : IRabbitMQService
    {
        private readonly ILogger<RabbitMQService> _logger;
        private readonly string _exchangeName = "EmailExchange";
        private readonly string _hostname;
        private readonly int _port;
        private readonly string _username;
        private readonly string _password;

        public RabbitMQService(ILogger<RabbitMQService> logger)
        {
            _logger = logger;
            _hostname = "localhost";
            _port = 5672;
            _username = "guest";
            _password = "guest";
        }

        public void SendMessage<T>(string routingKey, T message)
        {
            try
            {
                var factory = new ConnectionFactory
                {
                    HostName = _hostname,
                    Port = _port,
                    UserName = _username,
                    Password = _password
                };

                using var connection = factory.CreateConnection();
                using var channel = connection.CreateModel();

                channel.ExchangeDeclare(
                    exchange: _exchangeName,
                    type: ExchangeType.Direct,
                    durable: true,
                    autoDelete: false);

                var jsonMessage = JsonSerializer.Serialize(message);
                var body = Encoding.UTF8.GetBytes(jsonMessage);

                var properties = channel.CreateBasicProperties();
                properties.Persistent = true;

                channel.BasicPublish(
                    exchange: _exchangeName,
                    routingKey: routingKey,
                    basicProperties: properties,
                    body: body);

                _logger.LogInformation($"Message sent to exchange: {_exchangeName} with routing key: {routingKey}");
            }
            catch (BrokerUnreachableException ex)
            {
                _logger.LogInformation(ex, $"RabbitMQ broker unreachable at {_hostname}:{_port}. Ensure Docker/RabbitMQ is running and reachable.");
                Console.WriteLine($"ERROR: RabbitMQ broker unreachable at {_hostname}:{_port}. Ensure Docker/RabbitMQ is running and reachable.");
              
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error sending message to RabbitMQ exchange: {_exchangeName}");
                Console.WriteLine($"ERROR: Failed to send message to RabbitMQ: {ex.Message}");
                
            }
        }
    }
}

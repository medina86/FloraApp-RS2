using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Services.Interfaces
{
  
        public interface IRabbitMQService
        {
            void SendMessage<T>(string queueName, T message);
        }
    
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Requests
{
    public class CartItemRequest
    {
        public int CartId { get; set; } 
        public int? ProductId { get; set; }
        public int Quantity { get; set; } = 1;
        public string CardMessage { get; set; } = string.Empty;
        public string SpecialInstructions { get; set; } = string.Empty;
        public int? CustomBouquetId { get; set; }
    }
}

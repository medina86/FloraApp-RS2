using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Responses
{
    public class OrderDetailResponse
    {
        public int Id { get; set; }
        public int? ProductId { get; set; }
        public string? ProductName { get; set; } 
        public int? CustomBouquetId { get; set; }
        public string? ProductImageUrl { get; set; }
        public int Quantity { get; set; }
        public decimal PriceAtPurchase { get; set; }
        public string? CardMessage { get; set; }
        public string? SpecialInstructions { get; set; }
    }
}

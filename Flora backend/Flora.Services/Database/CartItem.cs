using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Services.Database
{
    public class CartItem
    {
        public int Id { get; set; }
        public int CartId { get; set; }
        public Cart Cart { get; set; }
        public Product Product { get; set; }
        public int? ProductId { get; set; }
        public string? ProductName { get; set; }
        public decimal Price { get; set; }
        public int Quantity { get; set; }
        public string? CardMessage { get; set; }
        public string? SpecialInstructions { get; set; }
        public string? ImageUrl { get; set; } = null;
        public int? CustomBouquetId { get; set; }  
        public CustomBouquet? CustomBouquet { get; set; }
    }

}

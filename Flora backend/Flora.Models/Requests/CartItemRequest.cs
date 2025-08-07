using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Requests
{
    public class CartItemRequest
    {
        [Required(ErrorMessage = "Cart ID is required")]
        public int CartId { get; set; } 
        
        // Either ProductId or CustomBouquetId must be provided, but validation is done at service level
        public int? ProductId { get; set; }
        
        [Required(ErrorMessage = "Quantity is required")]
        [Range(1, 100, ErrorMessage = "Quantity must be between 1 and 100")]
        public int Quantity { get; set; } = 1;
        
        public string CardMessage { get; set; } = string.Empty;
        
        public string SpecialInstructions { get; set; } = string.Empty;
        
        public int? CustomBouquetId { get; set; }
    }
}

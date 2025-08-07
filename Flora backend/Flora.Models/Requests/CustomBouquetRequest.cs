using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Requests
{
    public class CustomBouquetRequest
    {
        [Required(ErrorMessage = "Bouquet color is required")]
        public string Color { get; set; } = string.Empty;
        
        public string? CardMessage { get; set; }
        
        public string? SpecialInstructions { get; set; }
        
        [Required(ErrorMessage = "Total price is required")]
        [Range(0.01, 10000.00, ErrorMessage = "Total price must be between 0.01 and 10,000.00")]
        public decimal TotalPrice { get; set; }
        
        [Required(ErrorMessage = "User ID is required")]
        public int UserId { get; set; }
        
        [Required(ErrorMessage = "At least one bouquet item is required")]
        [MinLength(1, ErrorMessage = "Custom bouquet must contain at least one item")]
        public List<CustomBouquetItemRequest> CustomBouquetItems { get; set; } = new();
    }
}

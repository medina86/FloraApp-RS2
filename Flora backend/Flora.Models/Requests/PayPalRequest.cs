using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Requests
{
    public class PayPalPaymentRequest
    {
        [Required(ErrorMessage = "Order ID is required")]
        public int OrderId { get; set; }
        
        [Required(ErrorMessage = "Amount is required")]
        [Range(0.01, double.MaxValue, ErrorMessage = "Amount must be greater than 0")]
        public decimal Amount { get; set; }
        
        [Required(ErrorMessage = "Currency is required")]
        [MaxLength(3, ErrorMessage = "Currency code cannot exceed 3 characters")]
        public string Currency { get; set; } = "KM"; 
        
        [Required(ErrorMessage = "Return URL is required")]
        public string ReturnUrl { get; set; } = string.Empty;
        
        [Required(ErrorMessage = "Cancel URL is required")]
        public string CancelUrl { get; set; } = string.Empty;
    }
}

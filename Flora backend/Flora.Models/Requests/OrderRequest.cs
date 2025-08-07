using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Requests
{
    public class OrderRequest
    {
        [Required(ErrorMessage = "User ID is required")]
        public int UserId { get; set; }
        
        [Required(ErrorMessage = "Shipping address is required")]
        public ShippingAddressRequest ShippingAddress { get; set; } = null!;
        
        [Required(ErrorMessage = "Cart ID is required")]
        public int CartId { get; set; }
    }
}

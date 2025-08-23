using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Requests
{
    public class PayPalPaymentWithCartRequest
    {
        public int UserId { get; set; }
        public int CartId { get; set; }
        public ShippingAddressRequest ShippingAddress { get; set; }
        public decimal Amount { get; set; }
        public string Currency { get; set; } = "USD";
        public string ReturnUrl { get; set; }
        public string CancelUrl { get; set; }
    }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Requests
{
    public class PayPalPaymentRequest
    {
        public int OrderId { get; set; }
        public decimal Amount { get; set; }
        public string Currency { get; set; } = "KM"; 
        public string ReturnUrl { get; set; } 
        public string CancelUrl { get; set; } 
    }
}

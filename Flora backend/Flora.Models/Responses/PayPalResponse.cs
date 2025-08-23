using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Responses
{
    public class PayPalPaymentResponse
    {
        public string ApprovalUrl { get; set; }
        public string PaymentId { get; set; }
        
        // Dodatna polja za podršku novom toku plaćanja
        public int? CartId { get; set; }
        public int? UserId { get; set; }
    }
}

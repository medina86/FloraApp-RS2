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
    }
}

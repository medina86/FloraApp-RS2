using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Responses
{
    public class PayPalDonationResponse
    {
        public string ApprovalUrl { get; set; } = string.Empty;
        public string PaymentId { get; set; } = string.Empty;
        public int DonationId { get; set; }
    }
}

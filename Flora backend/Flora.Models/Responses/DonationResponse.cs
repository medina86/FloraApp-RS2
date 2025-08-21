using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Responses
{
    public class DonationResponse
    {
        public int Id { get; set; }
        public string DonorName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public string Purpose { get; set; } = string.Empty;
        public DateTime Date { get; set; }
        public int UserId {  get; set; }
        public int CampaignId { get; set; }
        public string Status { get; set; } = string.Empty;
        public string PaymentUrl { get;set; } = string.Empty;
        public string CampaignTitle { get; set; } = string.Empty;
        public string? TransactionId { get; set; }
    }

}

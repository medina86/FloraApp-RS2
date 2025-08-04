using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Services.Database
{
    public class Donation
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public User? User { get; set; }
        public string DonorName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public double Amount { get; set; }
        public string Purpose { get; set; } = string.Empty;
        public DateTime Date { get; set; } = DateTime.Now;
        public string? TransactionId { get; set; }
        public string Status { get; set; } = "Pending";

        public int CampaignId { get; set; }
        public virtual DonationCampaign? Campaign { get; set; }
    }
}

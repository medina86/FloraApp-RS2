using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Responses
{
    public class DonationCampaignResponse
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public DateTime EndDate { get; set; }
        public string? ImageUrl { get; set; }
        public decimal TotalAmount { get; set; }
    }

}

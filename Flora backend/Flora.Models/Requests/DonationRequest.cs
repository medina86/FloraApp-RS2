    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Threading.Tasks;

    namespace Flora.Models.Requests
    {
        public class DonationRequest
        {
            public string DonorName { get; set; } = string.Empty;
            public string Email { get; set; } = string.Empty;
            public decimal Amount { get; set; }
            public string Purpose { get; set; } = string.Empty;
            public int CampaignId { get; set; }
        }
    }

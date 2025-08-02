using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Requests
{
    public class DonationCampaignRequest
    {
        public string Title { get; set; }
        public string Description { get; set; }
        public DateTime EndDate { get; set; }
        public IFormFile? Image { get; set; }
    }
}

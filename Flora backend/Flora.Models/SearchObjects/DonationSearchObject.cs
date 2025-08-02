using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.SearchObjects
{
    public class DonationSearchObject : BaseSearchObject
    {
        public int? CampaignId { get; set; }
        public string? Email { get; set; }
    }

}

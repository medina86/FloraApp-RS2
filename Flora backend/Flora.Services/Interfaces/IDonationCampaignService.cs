using Flora.Models.Requests;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Services.Interfaces
{
    public interface IDonationCampaignService
     : ICRUDService<DonationCampaignResponse, DonationCampaignSearchObject, DonationCampaignRequest, DonationCampaignRequest>
    {
    }

}

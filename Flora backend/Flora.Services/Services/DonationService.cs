using Flora.Models.Requests;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using Flora.Services.Database;
using Flora.Services.Interfaces;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Services.Services
{
    public class DonationService
     : BaseCRUDService<DonationResponse, DonationSearchObject, Database.Donation, DonationRequest, DonationRequest>,
       IDonationService
    {
        public DonationService(FLoraDbContext context, IMapper mapper) : base(context, mapper) { }

        protected override async Task BeforeInsert(Database.Donation entity, DonationRequest request)
        {
            entity.Date = DateTime.Now;
        }

        protected override DonationResponse MapToResponse(Database.Donation entity)
        {
            var response = base.MapToResponse(entity);
            response.CampaignTitle = entity.Campaign?.Title ?? string.Empty;
            return response;
        }
    }

}

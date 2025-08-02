using Flora.Models.Requests;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using Flora.Services.Database;
using Flora.Services.Interfaces;
using MapsterMapper;
using Microsoft.SqlServer.Server;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Services.Services
{
    public class DonationCampaignService
    : BaseCRUDService<DonationCampaignResponse, DonationCampaignSearchObject, Database.DonationCampaign, DonationCampaignRequest, DonationCampaignRequest>,
      IDonationCampaignService
    {
        private readonly IBlobService _imageService;

        public DonationCampaignService(FLoraDbContext context, IMapper mapper, IBlobService imageService)
            : base(context, mapper)
        {
            _imageService = imageService;
        }

        protected override async Task BeforeInsert(Database.DonationCampaign entity, DonationCampaignRequest request)
        {
            if (request.Image != null)
            {
                entity.ImageUrl = await _imageService.UploadFileAsync(request.Image);
            }
        }

        protected override DonationCampaignResponse MapToResponse(Database.DonationCampaign entity)
        {
            var response = base.MapToResponse(entity);
            response.TotalAmount = entity.Donations?.Sum(d => (decimal)d.Amount) ?? 0;
            return response;
        }
    }

}

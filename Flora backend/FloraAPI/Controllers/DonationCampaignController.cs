using Flora.Models.Requests;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using Flora.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FloraAPI.Controllers
{
    [ApiController]
    [Authorize]
    [Route("api/[controller]")]
    public class DonationCampaignController : BaseCRUDController<DonationCampaignResponse, DonationCampaignSearchObject, DonationCampaignRequest, DonationCampaignRequest>
    {
        private readonly IDonationCampaignService _service;
        private readonly IBlobService _blobStorageService;
       
        public DonationCampaignController(IDonationCampaignService service, IBlobService blobStorageService) : base(service)
        {
            _service = service;
            _blobStorageService = blobStorageService;
        }

        [HttpPost]
        public override async Task<DonationCampaignResponse> Create([FromForm] DonationCampaignRequest request)
        {
            var result = await _service.CreateAsync(request);
            return result;
        }
        [HttpPut("{id}")]
        public override async Task<DonationCampaignResponse> Update(int id, [FromForm] DonationCampaignRequest request)
        {
            var result = await _service.UpdateAsync(id, request);
            return result;
        }
    }
    

}
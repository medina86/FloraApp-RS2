using Flora.Models.Requests;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using Flora.Services.Interfaces;
using Flora.Services.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FloraAPI.Controllers
{
    [ApiController]
    [Authorize]
    [Route("api/[controller]")]
    public class DonationController : BaseCRUDController<DonationResponse, DonationSearchObject, DonationRequest, DonationRequest>
    {
        private readonly IDonationService _donationService;
        public DonationController(IDonationService service) : base(service)
        {
            _donationService = service;
        }
        [HttpPost("initiate-paypal")]
        public async Task<DonationResponse> InitiatePayPalDonation([FromBody] DonationPayPalRequest request)
        {
            return await _donationService.CreatePayPalDonationAsync(request);
        }

        [HttpPost("confirm-paypal")]
        public async Task<DonationResponse> ConfirmPayPalDonation([FromQuery] int donationId, [FromQuery] string paymentId)
        {
            return await _donationService.ConfirmDonationPaymentAsync(donationId, paymentId);
        }

    }
}

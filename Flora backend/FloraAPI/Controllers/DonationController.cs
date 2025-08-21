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

        [HttpPost("initiatePayPalDonation")]
        public async Task<ActionResult<PayPalDonationResponse>> InitiatePayPalDonation([FromBody] PayPalDonationRequest request)
        {
            try
            {
                var response = await _donationService.InitiatePayPalDonationAsync(request);
                return Ok(response);
            }
            catch (Exception ex)
            {
                return BadRequest($"Error initiating PayPal donation: {ex.Message}");
            }
        }

        [HttpPost("confirm-paypal")]
        public async Task<DonationResponse> ConfirmPayPalDonation([FromQuery] int donationId, [FromQuery] string paymentId)
        {
            return await _donationService.ConfirmDonationPaymentAsync(donationId, paymentId);
        }

        [HttpPost("confirm-paypal-donation")]
        public async Task<ActionResult<DonationResponse>> ConfirmPayPalDonation2(
            [FromQuery] int donationId,
            [FromQuery] string paymentId)
        {
            try
            {
                var donation = await _donationService.ConfirmPayPalDonationAsync(donationId, paymentId);
                return Ok(donation);
            }
            catch (Exception ex)
            {
                return BadRequest($"Error confirming PayPal donation: {ex.Message}");
            }
        }

    }
}

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
    public interface IDonationService
    : ICRUDService<DonationResponse, DonationSearchObject, DonationRequest, DonationRequest>
    {
        Task<DonationResponse> InitiateDonationAsync(DonationPayPalRequest request);
        Task<DonationResponse> CreatePayPalDonationAsync(DonationPayPalRequest request);
        Task<DonationResponse> ConfirmDonationPaymentAsync(int donationId, string paymentId);

    }

}

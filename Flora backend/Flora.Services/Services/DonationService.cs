using Flora.Models.Requests;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using Flora.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System.Threading.Tasks;
using eCommerce.Services;
using Flora.Services.Database;
using Microsoft.Extensions.Configuration;

namespace Flora.Services.Services
{
    public class DonationService : BaseCRUDService<DonationResponse, DonationSearchObject, Donation, DonationRequest, DonationRequest>, IDonationService
    {
        private readonly FLoraDbContext _context;
        private readonly IMapper _mapper;
        private readonly IConfiguration _configuration;
        private readonly PayPalService _payPalService;

        public DonationService(FLoraDbContext context, IMapper mapper, IConfiguration configuration, PayPalService payPalService)
            : base(context, mapper)
        {
            _context = context;
            _mapper = mapper;
            _configuration = configuration;
            _payPalService = payPalService;
        }

        // Nova metoda - isti pattern kao OrderService
        public async Task<PayPalDonationResponse> InitiatePayPalDonationAsync(PayPalDonationRequest request)
        {
            try
            {
                var donation = await _context.Donations.FindAsync(request.DonationId);
                if (donation == null)
                {
                    throw new Exception($"Donation with ID {request.DonationId} not found.");
                }

                donation.Status = "PaymentInitiated";

                var returnUrl = "floraapp://paypal/donation/success";
                var cancelUrl = "floraapp://paypal/donation/cancel";
                var description = $"Flora Donation #{request.DonationId}";

                var payment = await _payPalService.CreatePayment(
                    request.Amount, 
                    request.Currency, 
                    description, 
                    returnUrl, 
                    cancelUrl
                );

                var approvalUrl = _payPalService.GetApprovalUrl(payment);

                if (string.IsNullOrEmpty(approvalUrl))
                {
                    throw new Exception("Failed to get PayPal approval URL for donation.");
                }

                // Sačuvaj payment ID u donaciju
                donation.TransactionId = payment.id;
                await _context.SaveChangesAsync();

                return new PayPalDonationResponse
                {
                    PaymentId = payment.id,
                    ApprovalUrl = approvalUrl,
                    DonationId = donation.Id
                };
            }
            catch (Exception ex)
            {
                throw new Exception($"Failed to initiate PayPal donation: {ex.Message}", ex);
            }
        }

        // Nova metoda - isti pattern kao OrderService  
        public async Task<DonationResponse> ConfirmPayPalDonationAsync(int donationId, string paymentId)
        {
            try
            {
                var donation = await _context.Donations
                    .Include(d => d.User)
                    .Include(d => d.Campaign)
                    .FirstOrDefaultAsync(d => d.Id == donationId);

                if (donation == null)
                    throw new Exception("Donation not found");

                if (string.IsNullOrEmpty(paymentId))
                    throw new Exception("Invalid PayPal payment ID for donation");

                // AUTOMATSKO ODOBRAVANJE - isti princip kao kod narudžbi
                Console.WriteLine($"Auto-approving PayPal donation for testing/development");

                // Direktno odobri donaciju
                donation.Status = "Completed";
                donation.TransactionId = paymentId;
                await _context.SaveChangesAsync();

                Console.WriteLine($"Donation {donationId} successfully processed via PayPal");
                return _mapper.Map<DonationResponse>(donation);
            }
            catch (Exception ex)
            {
                throw new Exception($"Failed to confirm PayPal donation: {ex.Message}", ex);
            }
        }

        // Stara metoda - kreiranje donacije + PayPal u jednom koraku
        public async Task<DonationResponse> CreatePayPalDonationAsync(DonationPayPalRequest request)
        {
            try
            {
                var donation = new Donation
                {
                    UserId = request.UserId,
                    CampaignId = request.CampaignId,
                    Amount = (double)request.Amount,
                    Status = "PaymentInitiated",
                    Date = DateTime.Now
                };

                _context.Donations.Add(donation);
                await _context.SaveChangesAsync();

                // Kreiraj pravi PayPal payment
                var returnUrl = "floraapp://paypal/donation/success";
                var cancelUrl = "floraapp://paypal/donation/cancel";
                var description = $"Flora Donation for Campaign #{request.CampaignId}";

                var payment = await _payPalService.CreatePayment(
                    request.Amount,
                    "USD",
                    description,
                    returnUrl,
                    cancelUrl
                );

                var approvalUrl = _payPalService.GetApprovalUrl(payment);

                if (string.IsNullOrEmpty(approvalUrl))
                {
                    throw new Exception("Failed to get PayPal approval URL for donation.");
                }

                // Sačuvaj payment ID
                donation.TransactionId = payment.id;
                await _context.SaveChangesAsync();

                return new DonationResponse
                {
                    Id = donation.Id,
                    DonorName = donation.User?.FirstName + " " + donation.User?.LastName,
                    Email = donation.User?.Email,
                    Purpose = donation.Purpose,
                    UserId = donation.UserId,
                    CampaignId = donation.CampaignId,
                    Amount = (decimal)donation.Amount,
                    Status = donation.Status,
                    PaymentUrl = approvalUrl,
                    TransactionId = payment.id
                };
            }
            catch (Exception ex)
            {
                throw new Exception($"Failed to create PayPal donation: {ex.Message}", ex);
            }
        }

        // Stara metoda - potvrđivanje plaćanja
        public async Task<DonationResponse> ConfirmDonationPaymentAsync(int donationId, string paymentId)
        {
            try
            {
                var donation = await _context.Donations
                    .Include(d => d.User)
                    .Include(d => d.Campaign)
                    .FirstOrDefaultAsync(d => d.Id == donationId);

                if (donation == null)
                    throw new Exception("Donation not found");

                if (string.IsNullOrEmpty(paymentId))
                    throw new Exception("Invalid PayPal payment ID for donation");

                
                donation.Status = "Completed";
                donation.TransactionId = paymentId;
                await _context.SaveChangesAsync();

                Console.WriteLine($"Donation {donationId} successfully processed via PayPal");
                return _mapper.Map<DonationResponse>(donation);
            }
            catch (Exception ex)
            {
                throw new Exception($"Failed to confirm PayPal donation: {ex.Message}", ex);
            }
        }

       
        public async Task<DonationResponse> InitiateDonationAsync(DonationPayPalRequest request)
        {
            var donation = new Donation
            {
                UserId = request.UserId,
                CampaignId = request.CampaignId,
                Amount = (double)request.Amount,
                Status = "Pending"
            };

            _context.Donations.Add(donation);
            await _context.SaveChangesAsync();

            var dummyPaymentId = Guid.NewGuid().ToString();
            var simulatedReturnUrl = $"{request.ReturnUrl}?donationId={donation.Id}&paymentId={dummyPaymentId}";

            donation.Status = "PaymentInitiated";
            await _context.SaveChangesAsync();

            return new DonationResponse
            {
                Id = donation.Id,
                UserId = donation.UserId,
                CampaignId = donation.CampaignId,
                Amount = (decimal)donation.Amount,
                Status = donation.Status,
                PaymentUrl = simulatedReturnUrl,
                DonorName = donation.User?.FirstName + " " + donation.User?.LastName,
                Email = donation.User?.Email,
                Purpose = donation.Purpose,
                TransactionId = dummyPaymentId
            };
        }

        protected override IQueryable<Donation> ApplyFilter(IQueryable<Donation> query, DonationSearchObject search)
        {
            query = query.Include(d => d.User);

            if (search?.CampaignId.HasValue == true)
            {
                query = query.Where(d => d.CampaignId == search.CampaignId.Value);
            }

            return query;
        }

        protected override DonationResponse MapToResponse(Donation entity)
        {
            var response = new DonationResponse
            {
                Id = entity.Id,
                UserId = entity.UserId,
                CampaignId = entity.CampaignId,
                Amount = (decimal)entity.Amount,
                Status = entity.Status,
                Date = entity.Date,
                Purpose = entity.Purpose,
                DonorName = entity.User != null ? entity.User.FirstName + " " + entity.User.LastName : "",
                Email = entity.User?.Email ?? "",
                CampaignTitle = entity.Campaign?.Title,
                TransactionId = entity.TransactionId
            };

            return response;
        }
    }
}

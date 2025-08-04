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

            public DonationService(FLoraDbContext context, IMapper mapper, IConfiguration configuration)
                : base(context, mapper)
            {
                _context = context;
                _mapper = mapper;
                _configuration = configuration;
            }
            public async Task<DonationResponse> CreatePayPalDonationAsync(DonationPayPalRequest request)
            {
                var donation = new Donation
                {
                    UserId = request.UserId,
                    CampaignId = request.CampaignId,
                    Amount = (double)request.Amount,
                    Status = "Pending",
                    Date = DateTime.Now
                };

                _context.Donations.Add(donation);
                await _context.SaveChangesAsync();

                var fakePaymentId = Guid.NewGuid().ToString();
                var redirectUrl = $"{request.ReturnUrl}?donationId={donation.Id}&paymentId={fakePaymentId}";

                donation.Status = "PaymentInitiated";
                donation.TransactionId = fakePaymentId;

                await _context.SaveChangesAsync();

                return new DonationResponse
                {
                    Id = donation.Id,
                    DonorName=donation.User.FirstName+" "+donation.User.LastName,
                    Email=donation.User.Email,
                    Purpose=donation.Purpose,
                    UserId = donation.UserId,
                    CampaignId = donation.CampaignId,
                    Amount = (decimal)donation.Amount,
                    Status = donation.Status,
                    PaymentUrl = redirectUrl
                };
            }

            public async Task<DonationResponse> ConfirmPayPalDonationAsync(int donationId, string paymentId)
            {
                var donation = await _context.Donations.FindAsync(donationId);
                if (donation == null)
                    throw new Exception("Donation not found");

                donation.Status = "Completed";
                donation.TransactionId = paymentId;

                await _context.SaveChangesAsync();

                return _mapper.Map<DonationResponse>(donation);
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
                    DonorName = donation.User.FirstName + " " + donation.User.LastName,
                    Email = donation.User.Email,
                    Purpose = donation.Purpose,
                };
            }

            public async Task<DonationResponse> ConfirmDonationPaymentAsync(int donationId, string paymentId)
            {
                var donation = await _context.Donations.FindAsync(donationId);
                if (donation == null)
                    throw new Exception("Donation not found.");

                donation.Status = "Completed";
                donation.TransactionId = paymentId;

                await _context.SaveChangesAsync();

                return _mapper.Map<DonationResponse>(donation);
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
                CampaignTitle = entity.Campaign?.Title ,
                
            };

            return response;
            }
        }

    }

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
    public class DonationController : BaseCRUDController<DonationResponse, DonationSearchObject, DonationRequest, DonationRequest>
    {
        public DonationController(IDonationService service) : base(service)
        {
        }
    }
}

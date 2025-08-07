using Flora.Models.Requests;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using Flora.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FloraAPI.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class DecorationSelectionController : BaseCRUDController<DecorationSelectionResponse, DecorationSelectionSearchObject, DecorationSelectionRequest, DecorationSelectionRequest>
    {
        private readonly IDecorationSelectionService _service;

        public DecorationSelectionController(IDecorationSelectionService service) : base(service)
        {
            _service = service;
        }

        [HttpGet("byRequest/{requestId}")]
        public async Task<ActionResult<DecorationSelectionResponse>> GetByRequestId(int requestId)
        {
            var selection = await _service.GetSelectionByRequestId(requestId);
            
            if (selection == null)
                return NotFound("No selection found for this request");

            return Ok(selection);
        }
    }
}

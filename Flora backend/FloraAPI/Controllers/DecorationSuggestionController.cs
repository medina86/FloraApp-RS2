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
    public class DecorationSuggestionController : BaseCRUDController<DecorationSuggestionResponse, DecorationSuggestionSearchObject, DecorationSuggestionRequest, DecorationSuggestionRequest>
    {
        private readonly IDecorationSuggestionService _service;
        public DecorationSuggestionController(IDecorationSuggestionService service) : base(service)
        {
            _service = service;
        }
        [HttpPost]
        public override async Task<DecorationSuggestionResponse> Create([FromForm] DecorationSuggestionRequest request)
        {
            var result = await _service.CreateAsync(request);
            return result;
        }
    }
}

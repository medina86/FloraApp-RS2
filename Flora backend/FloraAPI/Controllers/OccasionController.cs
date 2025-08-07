using Flora.Models.Requests;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using Flora.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace FloraAPI.Controllers
{
    public class OccasionController : BaseCRUDController<OccasionResponse, OccasionSearchObject, OccasionRequest, OccasionRequest>
    {
        private readonly IOccasionService _occasionService;

        public OccasionController(IOccasionService occasionService) : base(occasionService)
        {
            _occasionService = occasionService;
        }

        [HttpGet("all")]
        public async Task<IActionResult> GetAllOccasions()
        {
            try
            {
                var occasions = await _occasionService.GetAllAsync();
                return Ok(new { items = occasions });
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }
    }
}

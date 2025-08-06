using Flora.Models.Requests;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using Flora.Services.Interfaces;
using Flora.Services.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FloraAPI.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class CustomBouquetController : BaseCRUDController<
        CustomBouquetResponse, CustomBouquetSearchObject, CustomBouquetRequest, CustomBouquetRequest>
    {
        private readonly ICustomBouquetService _customBouquetService;
        public CustomBouquetController(ICustomBouquetService service) : base(service)
        {
            _customBouquetService = service;
        }
        [HttpGet("ByCartItem/{cartItemId}")]
        public async Task<IActionResult> GetByCartItemId(int cartItemId)
        {
            var result = await _customBouquetService.GetByCartItemIdAsync(cartItemId);

            if (result == null)
                return NotFound("Custom bouquet not found for the specified cart item");

            return Ok(result);
        }
    }

}

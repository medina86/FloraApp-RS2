using Flora.Models.Requests;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using Flora.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace FloraAPI.Controllers
{
    public class CartItemController : BaseCRUDController<CartItemResponse, CartItemSearchObject, CartItemRequest, CartItemRequest>
    {
        private readonly ICartItemService _cartItemService;
        public CartItemController(ICartItemService service) : base(service)
        {
            _cartItemService = service;
        }
        [HttpPost("{id}/increase")]
        public async Task<IActionResult> IncreaseQuantity(int id)
        {
            var result = await _cartItemService.IncreaseQuantityAsync(id);

            if (result == null)
                return NotFound("Cart item not found");

            return Ok(result);
        }

        [HttpPost("{id}/decrease")]
        public async Task<IActionResult> DecreaseQuantity(int id)
        {
            var (response, removed) = await _cartItemService.DecreaseQuantityAsync(id);

            if (removed)
                return Ok(new { message = "Item removed from cart", removed = true });

            if (response == null)
                return NotFound("Cart item not found");

            return Ok(response);
        }
    }
}
    
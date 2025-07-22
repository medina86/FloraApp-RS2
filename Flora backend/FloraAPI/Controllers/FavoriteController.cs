using Flora.Models.Requests;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using Flora.Services.Interfaces;
using Flora.Services.Services;
using MapsterMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FloraAPI.Controllers
{
    [Authorize]
    public class FavoriteController: BaseCRUDController<FavoriteResponse,FavoriteSearchObject,FavoriteRequest,FavoriteRequest>
    {
        private readonly IFavoriteService favoriteService;
        public FavoriteController(IFavoriteService service) :base(service)
        {
            favoriteService = service;
        }
        [HttpGet("details/user/{userId}")]
        public async Task<IActionResult> GetFavoriteDetails(int userId)
        {
            var favorites = await favoriteService.GetFavoriteProductIdsByUserAsync(userId);
            return Ok(favorites);
        }
    }
}

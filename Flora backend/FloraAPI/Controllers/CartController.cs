using Flora.Models.Requests;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using Flora.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;

namespace FloraAPI.Controllers
{

    [Authorize]
    public class CartController: BaseCRUDController<CartResponse, CartSearchObject, CartRequest,CartRequest>
    {
        public CartController(ICartService service):base(service) { }
    }
}

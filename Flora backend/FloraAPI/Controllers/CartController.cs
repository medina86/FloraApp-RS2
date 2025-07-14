using Flora.Models.Requests;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using Flora.Services.Interfaces;

namespace FloraAPI.Controllers
{
    public class CartController: BaseCRUDController<CartResponse, CartSearchObject, CartRequest,CartRequest>
    {
        public CartController(ICartService service):base(service) { }
    }
}

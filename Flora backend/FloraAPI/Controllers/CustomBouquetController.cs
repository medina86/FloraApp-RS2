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
    public class CustomBouquetController : BaseCRUDController<
        CustomBouquetResponse, CustomBouquetSearchObject, CustomBouquetRequest, CustomBouquetRequest>
    {
        public CustomBouquetController(ICustomBouquetService service) : base(service)
        {
        }
    }

}

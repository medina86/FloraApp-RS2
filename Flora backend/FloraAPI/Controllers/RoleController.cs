using Flora.Models.Requests;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using Flora.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FloraAPI.Controllers
{
    [AllowAnonymous]
    public class RoleController : BaseCRUDController<RoleResponse, RoleSearchObject, RoleRequest, RoleRequest>
    {
        public RoleController(IRoleService service) : base(service)
        {
        }

        [HttpGet]
        [AllowAnonymous]
        public override async Task<PagedResult<RoleResponse>> Get([FromQuery] RoleSearchObject? search = null)
        {
            return await _service.GetAsync(search ?? new RoleSearchObject());
        }

        [HttpGet("{id}")]
        [AllowAnonymous]
        public override async Task<RoleResponse?> GetById(int id)
        {
            return await _service.GetByIdAsync(id);
        }
    }
}
using Flora.Models.Requests;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using Flora.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FloraAPI.Controllers
{
    public class CategoryController:BaseCRUDController<CategoryResponse,CategorySearchObject, CategoryRequest,CategoryRequest>
    {
        public CategoryController(ICategoryService service) : base(service)
        {
        }

        [HttpGet]
        [AllowAnonymous]
        public override async Task<PagedResult<CategoryResponse>> Get([FromQuery] CategorySearchObject? search = null)
        {
            return await _service.GetAsync(search ?? new CategorySearchObject());
        }

        [HttpGet("{id}")]
        [AllowAnonymous]
        public override async Task<CategoryResponse?> GetById(int id)
        {
            return await _service.GetByIdAsync(id);
        }
    }
}

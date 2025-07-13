using Flora.Models.Requests;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using Flora.Services.Database;
using Flora.Services.Interfaces;
using Flora.Services.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace FloraAPI.Controllers
{
    public class CategoryController:BaseCRUDController<CategoryResponse,CategorySearchObject, CategoryRequest,CategoryRequest>
    {
       
        private readonly IBlobService _blobService;
        private readonly FLoraDbContext _context;
        private readonly ICategoryService _service;
        public CategoryController(ICategoryService service, IBlobService blobService, FLoraDbContext context) : base(service)
        {
            _blobService = blobService;
            _context = context;
            _service = service;
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
        public override async Task<CategoryResponse> Create([FromBody] CategoryRequest request)
        {
            return await _service.CreateAsync(request);
        }


    }
}

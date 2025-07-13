using Flora.Models.Requests;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using Flora.Services.Database;
using Flora.Services.Interfaces;
using MapsterMapper;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static System.Net.Mime.MediaTypeNames;

namespace Flora.Services.Services
{
    public class CategoryService : BaseCRUDService<CategoryResponse, CategorySearchObject, Database.Categories, CategoryRequest, CategoryRequest>, ICategoryService
    {
        private readonly IBlobService _blobService;
        private readonly IHttpContextAccessor _httpContextAccessor;
        public CategoryService(FLoraDbContext context, IMapper mapper, IBlobService blobService, IHttpContextAccessor httpContextAccessor) : base(context, mapper)
        {
            _blobService = blobService;
            _httpContextAccessor = httpContextAccessor;
        }
        protected override IQueryable<Database.Categories> ApplyFilter(IQueryable<Database.Categories> query, CategorySearchObject search)
        {
            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(r => r.Name.Contains(search.FTS) || r.Description.Contains(search.FTS));
            }

            return query;
        }

        protected override async Task BeforeInsert(Database.Categories entity, CategoryRequest request)
        {
            if (await _context.Categories.AnyAsync(r => r.Name == request.Name))
            {
                throw new InvalidOperationException("A category with this name already exists.");
            }
        }

        protected override async Task BeforeUpdate(Database.Categories entity, CategoryRequest request)
        {
            if (await _context.Categories.AnyAsync(r => r.Name == request.Name && r.Id != entity.Id))
            {
                throw new InvalidOperationException("A category with this name already exists.");
            }
        }
        public override async Task<CategoryResponse> CreateAsync(CategoryRequest request)
        {
            var entity = new Categories
            {
                Name = request.Name,
                Description = request.Description,
                CategoryImageUrl = request.CategoryImageUrl
            };

            await BeforeInsert(entity, request);

            _context.Categories.Add(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<CategoryResponse>(entity);
        }
        protected override Categories MapInsertToEntity(Categories entity, CategoryRequest request)
        {
            entity = base.MapInsertToEntity(entity, request);

            entity.CategoryImageUrl = request.CategoryImageUrl;

            return entity;
        }

    }


}


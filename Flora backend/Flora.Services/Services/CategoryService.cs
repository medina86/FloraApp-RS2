using Flora.Models.Requests;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using Flora.Services.Database;
using Flora.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Services.Services
{
    public class CategoryService : BaseCRUDService<CategoryResponse, CategorySearchObject, Database.Categories, CategoryRequest, CategoryRequest>, ICategoryService
    {
        public CategoryService(FLoraDbContext context, IMapper mapper): base(context,mapper) { 
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
    }
}

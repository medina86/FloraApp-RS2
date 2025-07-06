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
        public class ProductService : BaseCRUDService<ProductResponse, ProductSearchObject, Database.Product, ProductRequest, ProductRequest>, IProductService
        {
            public ProductService(FLoraDbContext context, IMapper mapper) : base(context, mapper)
            {
            }
            protected override IQueryable<Product> ApplyFilter(IQueryable<Product> query, ProductSearchObject search)
            {
                   query = query
               .Include(p => p.Category)
               .Include(p => p.Occasion);


            if (!string.IsNullOrEmpty(search.Name))
                {
                    query = query.Where(p => p.Name.Contains(search.Name));
                }

                if (search.CategoryId.HasValue)
                {
                    query = query.Where(p => p.CategoryId == search.CategoryId.Value);
                }
                if(search.MinPrice.HasValue && search.MaxPrice.HasValue)
                {
                    query=query.Where(p=>p.Price<=search.MaxPrice.Value && p.Price>=search.MinPrice);
                }

                return query;
            }
            protected override async Task BeforeInsert(Product entity, ProductRequest request)
            {
                if (await _context.Products.AnyAsync(p => p.Name == request.Name))
                {
                    throw new InvalidOperationException("A product with this name already exists.");
                }
            }
            protected override async Task BeforeUpdate(Product entity, ProductRequest request)
            {
                if (await _context.Products.AnyAsync(p => p.Name == request.Name && p.Id != entity.Id))
                {
                    throw new InvalidOperationException("A product with this name already exists.");
                }
            }

            public async Task<List<Product>> GetByCategoryIdAsync(int categoryId)
            {
                return await _context.Products
                    .Where(p => p.CategoryId == categoryId)
                    .ToListAsync();
            }

            public async Task<List<Product>> GetNewProductsAsync()
            {
                return await _context.Products
                    .Where(p => p.IsNew)
                    .ToListAsync();
            }

            public async Task<List<Product>> GetFeaturedProductsAsync()
            {
                return await _context.Products
                    .Where(p => p.IsFeatured)
                    .ToListAsync();
            }

            public async Task<List<Product>> GetByOccasionAsync(int occasionId)
            {
                return await _context.Products
                    .Where(p => p.OccasionId == occasionId)
                    .ToListAsync();
            }
        protected override Product MapInsertToEntity(Product entity, ProductRequest request)
        {
            entity = base.MapInsertToEntity(entity, request);

            if (request.Images != null)
            {
                entity.Images = request.Images
                    .Select(url => new ProductImages { ImageUrl = url })
                    .ToList();
            }

            return entity;
        }
        protected override ProductResponse MapToResponse(Product entity)
        {
            var response = base.MapToResponse(entity);
            response.CategoryName = entity.Category?.Name;
            response.OccasionName = entity.Occasion?.Name;
            return response;
        }


    }

}

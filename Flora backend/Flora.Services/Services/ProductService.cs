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

    namespace Flora.Services.Services
    {
        public class ProductService : BaseCRUDService<ProductResponse, ProductSearchObject, Database.Product, ProductRequest, ProductRequest>, IProductService
        {

        private readonly IBlobService _blobService;
        public ProductService(FLoraDbContext context, IMapper mapper,IBlobService bls) : base(context, mapper)
            {
            _blobService = bls;
            }
            protected override IQueryable<Product> ApplyFilter(IQueryable<Product> query, ProductSearchObject search)
            {
            query = query
                    .Include(p => p.Category)
        .Include(p => p.Occasion)
     .Include(p => p.Images);
            if (!string.IsNullOrEmpty(search.OccasionName))
            {
                var lowerOccasionName = search.OccasionName.ToLower();
                query = query.Where(p => p.Occasion != null && p.Occasion.Name.ToLower() == lowerOccasionName);
            }
            if (!string.IsNullOrEmpty(search.CategoryName))
            {
                var lowerOccasionName = search.CategoryName.ToLower();
                query = query.Where(p => p.Category != null && p.Category.Name.ToLower() == lowerOccasionName);
            }
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
            if (search.Active != null)
            {
                query = query.Where(p => p.Active == search.Active);
            }
            

            if (search.IsAvailable != null)
            {
                query = query.Where(p => p.IsAvailable == search.IsAvailable);
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
            
    protected override async Task BeforeDelete(Product entity)
    {
        // Pronađi i obriši sve CartItem zapise koji referenciraju ovaj proizvod
        var cartItems = await _context.CartItems
            .Where(ci => ci.ProductId == entity.Id)
            .ToListAsync();
            
        if (cartItems.Any())
        {
            _context.CartItems.RemoveRange(cartItems);
        }
        
        // Pronađi i postavi ProductId na null za sve OrderDetail zapise
        var orderDetails = await _context.OrderDetails
            .Where(od => od.ProductId == entity.Id)
            .ToListAsync();
            
        foreach (var detail in orderDetails)
        {
            detail.ProductId = null;
            detail.Product = null;
        }
        
        await _context.SaveChangesAsync();
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

        public async Task<List<Product>> GetByOccasionAsync(string occasionName)
        {
            return await _context.Products
                .Include(p => p.Occasion)
                .Include(p => p.Images)
                .Include(p => p.Category)
                .Where(p => p.Occasion != null &&
                            p.Occasion.Name.ToLower() == occasionName.ToLower())
                .Where(p => p.Active && p.IsAvailable)
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
            response.ImageUrls = entity.Images?.Select(i => i.ImageUrl).ToList() ?? new();
            return response;
        }
        public async Task<List<string>> UploadMultipleImages(int productId, List<IFormFile> files)
        {
            var product = await _context.Products
                .Include(p => p.Images)
                .FirstOrDefaultAsync(p => p.Id == productId);

            if (product == null)
                throw new Exception("Product not found.");

            var urls = new List<string>();

            foreach (var file in files)
            {
                var imageUrl = await _blobService.UploadFileAsync(file);

                var productImage = new ProductImages
                {
                    ProductId = productId,
                    ImageUrl = imageUrl
                };

                product.Images.Add(productImage);
                urls.Add(imageUrl);
            }

            await _context.SaveChangesAsync();
            return urls;
        }
        public async Task<List<string>> GetImagesForProduct(int productId)
        {
            var product = await _context.Products
                .Include(p => p.Images)
                .FirstOrDefaultAsync(p => p.Id == productId);

            if (product == null)
                throw new Exception("Product not found.");

            return product.Images
                .Select(img => img.ImageUrl)
                .ToList();
        }
        public ProductResponse MapProductToResponse(Product entity)
        {
            return MapToResponse(entity);
        }
    }

}

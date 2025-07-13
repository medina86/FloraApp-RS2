    using Flora.Models.Requests;
    using Flora.Models.Responses;
    using Flora.Models.SearchObjects;
    using Flora.Services.Database;
    using Microsoft.AspNetCore.Http;
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Threading.Tasks;

    namespace Flora.Services.Interfaces
    {
        public interface IProductService : ICRUDService<ProductResponse,ProductSearchObject,ProductRequest,ProductRequest>
        {
            Task<List<Product>> GetByCategoryIdAsync(int categoryId);
            Task<List<Product>> GetNewProductsAsync();
            Task<List<Product>> GetFeaturedProductsAsync();
            Task<List<Product>> GetByOccasionAsync(string name);
            Task<List<string>> UploadMultipleImages(int productId, List<IFormFile> files);
            Task<List<string>>GetImagesForProduct(int productId);

        }
    }

using Flora.Models.Requests;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using Flora.Services.Interfaces;
using MapsterMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace FloraAPI.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class ProductController : BaseCRUDController<ProductResponse, ProductSearchObject, ProductRequest, ProductRequest>
    {
        private readonly IProductService _productService;
        private readonly IMapper _mapper;

        public ProductController(IProductService service, IMapper mapper) : base(service)
        {
            _productService = service;
            _mapper = mapper;
        }

        [HttpGet("new")]
        public async Task<ActionResult<List<ProductResponse>>> GetNewProducts()
        {
            var products = await _productService.GetNewProductsAsync();
            var result = products.Select(p => _mapper.Map<ProductResponse>(p)).ToList();
            return Ok(result);
        }

        [HttpGet("featured")]
        public async Task<ActionResult<List<ProductResponse>>> GetFeaturedProducts()
        {
            var products = await _productService.GetFeaturedProductsAsync();
            var result = products.Select(p => _mapper.Map<ProductResponse>(p)).ToList();
            return Ok(result);
        }

        [HttpGet("recommended/{userId}")]
        public async Task<ActionResult<List<ProductResponse>>> GetRecommendedProducts(int userId)
        {
            // Redirect to Recommendations controller
            var products = await _productService.GetFeaturedProductsAsync();
            var result = products.Select(p => _mapper.Map<ProductResponse>(p)).ToList();
            return Ok(result);
        }

        [HttpGet("by-category/{categoryId}")]
        public async Task<ActionResult<List<ProductResponse>>> GetByCategory(int categoryId)
        {
            var products = await _productService.GetByCategoryIdAsync(categoryId);
            var result = products.Select(p => _mapper.Map<ProductResponse>(p)).ToList();
            return Ok(result);
        }

        [HttpGet("by-occasion/{name}")]
        public async Task<ActionResult<List<ProductResponse>>> GetByOccasion(string name)
        {
            var products = await _productService.GetByOccasionAsync(name);
            var result = products.Select(p => _mapper.Map<ProductResponse>(p)).ToList();

            return Ok(result);
        }
           
        [HttpPost("{productId}/upload-images")]
        public async Task<IActionResult> UploadMultipleImages(int productId, [FromForm] List<IFormFile> files)
        {
            if (files == null || files.Count == 0)
                return BadRequest("No files uploaded.");

            var urls = await _productService.UploadMultipleImages(productId, files);

            return Ok(urls); 
        }
        [HttpGet("product_image_{productId}")]
        public async Task<IActionResult> GetImagesForProduct(int productId)
        {
            try
            {
                var images = await _productService.GetImagesForProduct(productId);
                return Ok(images);
            }
            catch (Exception ex)
            {
                return NotFound(ex.Message);
            }
        }


    }
}

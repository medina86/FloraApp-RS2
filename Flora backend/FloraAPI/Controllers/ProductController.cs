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
    [AllowAnonymous]
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
        [AllowAnonymous]
        public async Task<ActionResult<List<ProductResponse>>> GetNewProducts()
        {
            var products = await _productService.GetNewProductsAsync();
            var result = products.Select(p => _mapper.Map<ProductResponse>(p)).ToList();
            return Ok(result);
        }

        [HttpGet("featured")]
        [AllowAnonymous]
        public async Task<ActionResult<List<ProductResponse>>> GetFeaturedProducts()
        {
            var products = await _productService.GetFeaturedProductsAsync();
            var result = products.Select(p => _mapper.Map<ProductResponse>(p)).ToList();
            return Ok(result);
        }

        [HttpGet("by-category/{categoryId}")]
        [AllowAnonymous]
        public async Task<ActionResult<List<ProductResponse>>> GetByCategory(int categoryId)
        {
            var products = await _productService.GetByCategoryIdAsync(categoryId);
            var result = products.Select(p => _mapper.Map<ProductResponse>(p)).ToList();
            return Ok(result);
        }

        [HttpGet("by-occasion/{occasionId}")]
        [AllowAnonymous]
        public async Task<ActionResult<List<ProductResponse>>> GetByOccasion(int occasionId)
        {
            var products = await _productService.GetByOccasionAsync(occasionId);
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

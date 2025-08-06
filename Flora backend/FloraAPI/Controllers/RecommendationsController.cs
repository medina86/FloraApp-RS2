using Flora.Models.Recommendations;
using Flora.Models.Responses;
using Flora.Services.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Text.Json;

namespace FloraAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class RecommendationsController : ControllerBase
    {
        private readonly IRecommendationService _recommendationService;
        private readonly ILogger<RecommendationsController> _logger;

        public RecommendationsController(IRecommendationService recommendationService, ILogger<RecommendationsController> logger)
        {
            _recommendationService = recommendationService;
            _logger = logger;
        }

        [HttpGet("products/{productId}")]
        public async Task<ActionResult<List<ProductResponse>>> GetProductRecommendations(int productId, [FromQuery] int topN = 5)
        {
            try
            {
                var recommendations = await _recommendationService.GetRecommendedProductsAsync(productId, topN);
                _logger.LogInformation("Dohvaćeno {Count} preporuka za proizvod ID: {ProductId}", recommendations.Count, productId);
                return Ok(recommendations);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Greška prilikom dohvaćanja preporuka za proizvod ID: {ProductId}", productId);
                return StatusCode(StatusCodes.Status500InternalServerError, "Došlo je do greške prilikom dohvaćanja preporuka");
            }
        }

        [HttpPost("recalculate")]
        public async Task<IActionResult> RecalculateRecommendations()
        {
            try
            {
                await _recommendationService.RecalculateSimilarityMapAsync();
                return Ok("Izračun sličnosti proizvoda je uspješno pokrenut");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Greška prilikom izračuna sličnosti proizvoda");
                return StatusCode(StatusCodes.Status500InternalServerError, "Došlo je do greške prilikom izračuna sličnosti proizvoda");
            }
        }
        [HttpGet("co-purchases")]
        public async Task<ActionResult<List<ProductCoPurchase>>> GetCoPurchaseMap()
        {
            try
            {
                var coPurchaseMap = await _recommendationService.GetCoPurchaseMapAsync();
                return Ok(coPurchaseMap);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Greška prilikom dohvaćanja mape ko-kupovina");
                return StatusCode(StatusCodes.Status500InternalServerError, "Došlo je do greške prilikom dohvaćanja mape ko-kupovina");
            }
        }
        
        [HttpGet("user/{userId}")]
        public async Task<ActionResult<List<ProductResponse>>> GetRecommendationsForUser(int userId, [FromQuery] int maxResults = 10)
        {
            try
            {
                var recommendations = await _recommendationService.GetRecommendedForUserAsync(userId, maxResults);
                _logger.LogInformation("Dohvaćeno {Count} preporuka za korisnika ID: {UserId}", recommendations.Count, userId);
                return Ok(recommendations);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Greška prilikom dohvaćanja preporuka za korisnika ID: {UserId}", userId);
                return StatusCode(StatusCodes.Status500InternalServerError, "Došlo je do greške prilikom dohvaćanja preporuka za korisnika");
            }
        }
    }
}

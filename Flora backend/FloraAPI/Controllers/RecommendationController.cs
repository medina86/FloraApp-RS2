using Flora.Models.Responses;
using Flora.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace FloraAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class RecommendationController : ControllerBase
    {
        private readonly IRecommendationService _recommendationService;
        private readonly ILogger<RecommendationController> _logger;

        public RecommendationController(IRecommendationService recommendationService, ILogger<RecommendationController> logger)
        {
            _recommendationService = recommendationService;
            _logger = logger;
        }

        [HttpGet("initialize")]
        public async Task<IActionResult> InitializeRecommendations()
        {
            try
            {
                _logger.LogInformation("Pokretanje inicijalizacije sistema preporuka");
                await _recommendationService.RecalculateSimilarityMapAsync();
                return Ok(new { message = "Sistem preporuka uspješno inicijalizovan" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Greška prilikom inicijalizacije sistema preporuka");
                return StatusCode(500, new { message = "Došlo je do greške prilikom inicijalizacije sistema preporuka" });
            }
        }

        [HttpGet("product/{productId}")]
        public async Task<ActionResult<List<ProductResponse>>> GetRecommendedProducts(int productId, [FromQuery] int count = 5)
        {
            try
            {
                var recommendations = await _recommendationService.GetRecommendedProductsAsync(productId, count);
                return Ok(recommendations);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Greška prilikom dohvaćanja preporuka za proizvod {ProductId}", productId);
                return StatusCode(500, new { message = "Došlo je do greške prilikom dohvaćanja preporuka" });
            }
        }

        [HttpGet("user/{userId}")]
        public async Task<ActionResult<List<ProductResponse>>> GetRecommendedForUser(int userId, [FromQuery] int count = 10)
        {
            try
            {
                var recommendations = await _recommendationService.GetRecommendedForUserAsync(userId, count);
                return Ok(recommendations);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Greška prilikom dohvaćanja preporuka za korisnika {UserId}", userId);
                return StatusCode(500, new { message = "Došlo je do greške prilikom dohvaćanja preporuka" });
            }
        }
    }
}


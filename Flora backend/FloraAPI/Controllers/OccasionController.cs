using Microsoft.AspNetCore.Mvc;

[ApiController]
[Route("api/[controller]")]
public class OccasionController : ControllerBase
{
    private readonly IOccasionService _occasionService;

    public OccasionController(IOccasionService occasionService)
    {
        _occasionService = occasionService;
    }

    [HttpGet]
    public async Task<IActionResult> GetOccasions()
    {
        try
        {
            var occasions = await _occasionService.GetAllAsync();
            return Ok(new { items = occasions });
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"Internal server error: {ex.Message}");
        }
    }
}

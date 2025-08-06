using Flora.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class StatisticsController : ControllerBase
{
    private readonly IStatisticsService _statisticsService;

    public StatisticsController(IStatisticsService statisticsService)
    {
        _statisticsService = statisticsService;
    }

    [HttpGet("total-users")]
    public async Task<IActionResult> GetTotalUsers() =>
        Ok(await _statisticsService.GetTotalUsers());

    [HttpGet("total-orders")]
    public async Task<IActionResult> GetTotalOrders() =>
        Ok(await _statisticsService.GetTotalOrders());

    [HttpGet("orders-by-month")]
    public async Task<IActionResult> GetOrdersByMonth() =>
        Ok(await _statisticsService.GetOrdersByMonth());

    [HttpGet("reservations-by-month")]
    public async Task<IActionResult> GetReservationsByMonth() =>
        Ok(await _statisticsService.GetReservationsByMonth());

    [HttpGet("summary")]
    public async Task<IActionResult> GetSummary([FromQuery] DateTime startDate, [FromQuery] DateTime endDate) =>
        Ok(await _statisticsService.GetSummary(startDate, endDate));

    [HttpGet("generate-report")]
    public async Task<IActionResult> GenerateReport([FromQuery] DateTime startDate, [FromQuery] DateTime endDate)
    {
        var report = await _statisticsService.GeneratePdfReport(startDate, endDate);
        return File(report, "application/pdf", "Report.pdf");
    }
}

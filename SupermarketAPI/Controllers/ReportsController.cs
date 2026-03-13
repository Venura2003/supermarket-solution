using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SupermarketAPI.Services;

namespace SupermarketAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "Admin,Manager,Sales")]
    public class ReportsController : ControllerBase
    {
        private readonly IReportService _reportService;

        public ReportsController(IReportService reportService)
        {
            _reportService = reportService;
        }

        [HttpGet("daily-sales")]
        public async Task<IActionResult> GetDailySales([FromQuery] DateTime? date)
        {
            var d = date ?? DateTime.UtcNow.Date;
            var report = await _reportService.GetDailySalesAsync(d);
            return Ok(report);
        }

        [HttpGet("monthly-sales")]
        public async Task<IActionResult> GetMonthlySales([FromQuery] int? year, [FromQuery] int? month)
        {
            var y = year ?? DateTime.UtcNow.Year;
            var m = month ?? DateTime.UtcNow.Month;
            var report = await _reportService.GetMonthlySalesAsync(y, m);
            return Ok(report);
        }

        [HttpGet("top-products")]
        public async Task<IActionResult> GetTopProducts([FromQuery] int limit = 10)
        {
            var topProducts = await _reportService.GetTopSellingProductsAsync(limit);
            return Ok(topProducts);
        }
        [HttpGet("profit-summary")]
        public async Task<IActionResult> GetProfitSummary([FromQuery] DateTime? startDate, [FromQuery] DateTime? endDate)
        {
            var summary = await _reportService.GetProfitSummaryAsync(startDate, endDate);
            return Ok(summary);
        }
    }
}

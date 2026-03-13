using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SupermarketAPI.DTOs;
using SupermarketAPI.Services;

namespace SupermarketAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class PayrollController : ControllerBase
    {
        private readonly IPayrollService _service;
        private readonly ILogger<PayrollController> _logger;

        public PayrollController(IPayrollService service, ILogger<PayrollController> logger)
        {
            _service = service;
            _logger = logger;
        }

        [HttpPost("advance")]
        [Authorize(Roles = "Admin,Manager")]
        public async Task<IActionResult> CreateAdvance([FromBody] CreateSalaryAdvanceDto dto)
        {
            try
            {
                var advance = await _service.CreateAdvanceAsync(dto);
                return Ok(advance);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating salary advance");
                return StatusCode(500, new { message = "Error creating advance" });
            }
        }

        [HttpGet("advances/pending/{employeeId}")]
        public async Task<IActionResult> GetPendingAdvances(int employeeId)
        {
            try 
            {
                var advances = await _service.GetPendingAdvancesAsync(employeeId);
                return Ok(advances);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting pending advances");
                return StatusCode(500, new { message = "Error getting pending advances" });
            }
        }

        [HttpPost]
        [Authorize(Roles = "Admin,Manager")]
        public async Task<IActionResult> CreatePayroll([FromBody] CreatePayrollDto dto)
        {
            try
            {
                var payroll = await _service.CreatePayrollAsync(dto);
                return Ok(new { message = "Payroll generated successfully", id = payroll.Id });
            }
            catch (Exception ex)
            {
                 _logger.LogError(ex, "Error creating payroll");
                 return StatusCode(500, new { message = "Error creating payroll" });
            }
        }

        [HttpGet("history")]
        public async Task<IActionResult> GetPayrollHistory()
        {
            try
            {
                var history = await _service.GetPayrollHistoryAsync();
                return Ok(history);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting payroll history");
                return StatusCode(500, new { message = "Error getting payroll history" });
            }
        }
        
        [HttpGet("history/{employeeId}")]
        public async Task<IActionResult> GetEmployeePayrollHistory(int employeeId)
        {
            try
            {
                var history = await _service.GetEmployeePayrollHistoryAsync(employeeId);
                return Ok(history);
            }
            catch (Exception ex)
            {
                 _logger.LogError(ex, "Error getting employee payroll history");
                 return StatusCode(500, new { message = "Error getting employee payroll history" });
            }
        }
    }
}

using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SupermarketAPI.DTOs;
using SupermarketAPI.Services;
using Microsoft.Data.SqlClient;
using System.Data;
using Microsoft.Extensions.Configuration;

namespace SupermarketAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Produces("application/json")]
    public class SalesController : ControllerBase
    {
        private readonly ISaleService _saleService;
        private readonly IOrderService _orderService;
        private readonly IEmployeeService _employeeService;
        private readonly ICartService _cartService;
        private readonly ILogger<SalesController> _logger;

        public SalesController(
            ISaleService saleService, 
            IOrderService orderService,
            IEmployeeService employeeService,
            ICartService cartService,
            ILogger<SalesController> logger)
        {
            _saleService = saleService;
            _orderService = orderService;
            _employeeService = employeeService;
            _cartService = cartService;
            _logger = logger;
        }

        [HttpGet]
        [Authorize(Roles = "Admin,Employee")]
        public async Task<IActionResult> GetAll()
        {
            var sales = await _saleService.GetAllAsync();
            return Ok(new ApiResponse<IEnumerable<SaleDto>>
            {
                Success = true,
                Data = sales,
                Message = "Sales retrieved successfully"
            });
        }

        [HttpGet("{id}")]
        [Authorize(Roles = "Admin,Employee")]
        public async Task<IActionResult> Get(int id)
        {
            var sale = await _saleService.GetByIdAsync(id);
            if (sale == null)
                return NotFound(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Sale not found"
                });

            return Ok(new ApiResponse<SaleDto>
            {
                Success = true,
                Data = sale,
                Message = "Sale retrieved successfully"
            });
        }

        [HttpPost]
        [Authorize(Roles = "Admin,Employee")]
        public async Task<IActionResult> Create([FromBody] CreateSaleDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Invalid request data",
                    Errors = ModelState.Values.SelectMany(v => v.Errors.Select(e => e.ErrorMessage))
                });

            try
            {
                var (userId, email) = GetUserClaims();
                if (!userId.HasValue && string.IsNullOrEmpty(email))
                     return Unauthorized(new ApiResponse<object> { Success = false, Message = "Invalid credentials" });

                var employee = await _employeeService.GetEmployeeByUserIdOrEmailAsync(userId, email);
                
                if (employee == null)
                {
                    try 
                    {
                        var newEmpDto = new CreateEmployeeDto(
                            userId, 
                            email ?? $"user_{userId}", 
                            email ?? $"user_{userId}@system.local", 
                            "", 
                            "Employee", 
                            0, 
                            DateTime.UtcNow
                        );
                        employee = await _employeeService.CreateEmployeeAsync(newEmpDto);
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "Failed to auto-provision employee during sale creation");
                         return StatusCode(500, new ApiResponse<object> { Success = false, Message = "Failed to resolve employee profile" });
                    }
                }

                var created = await _saleService.CreateAsync(dto, employee.Id);
                return CreatedAtAction(nameof(Get), new { id = created.Id },
                    new ApiResponse<SaleDto>
                    {
                        Success = true,
                        Data = created,
                        Message = "Sale created successfully"
                    });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to create sale");
                var msg = ex.Message;
                if (ex.InnerException != null) msg += $" | Inner: {ex.InnerException.Message}";
                
                return StatusCode(500, new ApiResponse<object>
                {
                    Success = false,
                    Message = msg,
                    Errors = new[] { ex.ToString() }
                });
            }
        }

        [HttpPost("checkout")]
        [Authorize(Roles = "Admin,Employee")]
        public async Task<IActionResult> Checkout([FromBody] CreateOrderDto dto)
        {
            if (dto == null || dto.Items == null || !dto.Items.Any())
            {
                return BadRequest(new ApiResponse<object> { Success = false, Message = "Order items are required" });
            }

            try
            {
                var (userId, email) = GetUserClaims();
                _logger.LogInformation("[Checkout] User: {UserId}, Email: {Email}, Items: {Count}", userId, email, dto.Items.Count);

                var employee = await _employeeService.GetEmployeeByUserIdOrEmailAsync(userId, email);
                if (employee == null)
                {
                     return StatusCode(500, new ApiResponse<object> { Success = false, Message = "Employee profile not found. Please contact admin." });
                }

                var created = await _orderService.CreateOrderAsync(dto, employee.Id);
                
                // Clear cart
                _cartService.ClearCart(employee.Id);
                
                var receiptPath = await _orderService.GenerateReceiptAsync(created.Id);

                return Ok(new ApiResponse<object>
                {
                    Success = true,
                    Data = new { sale = created, receiptPath = receiptPath },
                    Message = "Order created successfully"
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[Checkout] Order failed");
                return StatusCode(500, new ApiResponse<object>
                {
                    Success = false,
                    Message = ex.Message ?? "Order processing failed",
                    Errors = new[] { ex.ToString() }
                });
            }
        }

        private (int? userId, string? email) GetUserClaims()
        {
            var idClaim = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value 
                          ?? User.FindFirst("id")?.Value;
            
            int? userId = null;
            if (int.TryParse(idClaim, out var parsed)) userId = parsed;

            var email = User.FindFirst(System.Security.Claims.ClaimTypes.Email)?.Value;
            
            return (userId, email);
        }



        // Serve generated receipt files
        [HttpGet("receipts/{fileName}")]
        [AllowAnonymous]
        public IActionResult DownloadReceiptFile(string fileName)
        {
            try
            {
                var receiptsDir = Path.Combine(Directory.GetCurrentDirectory(), "Receipts");
                var fullPath = Path.Combine(receiptsDir, fileName);
                if (!System.IO.File.Exists(fullPath)) return NotFound(new ApiResponse<object> { Success = false, Message = "Receipt not found" });

                var bytes = System.IO.File.ReadAllBytes(fullPath);
                return File(bytes, "application/pdf", fileName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to read receipt file {FileName}", fileName);
                return StatusCode(500, new ApiResponse<object> { Success = false, Message = "Failed to read receipt" });
            }
        }

        [HttpGet("employee/{employeeId}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> GetByEmployee(int employeeId)
        {
            var sales = await _saleService.GetByEmployeeAsync(employeeId);
            return Ok(new ApiResponse<IEnumerable<SaleDto>>
            {
                Success = true,
                Data = sales,
                Message = "Employee sales retrieved successfully"
            });
        }

        [HttpGet("daterange")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> GetByDateRange([FromQuery] DateTime startDate, [FromQuery] DateTime endDate)
        {
            if (startDate > endDate)
                return BadRequest(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Start date cannot be after end date"
                });

            var sales = await _saleService.GetByDateRangeAsync(startDate, endDate);
            return Ok(new ApiResponse<IEnumerable<SaleDto>>
            {
                Success = true,
                Data = sales,
                Message = "Sales retrieved successfully"
            });
        }
    }
}
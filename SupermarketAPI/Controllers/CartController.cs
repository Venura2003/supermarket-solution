using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Data.SqlClient;
using System.Linq;
using SupermarketAPI.DTOs;
using SupermarketAPI.Services;

namespace SupermarketAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CartController : ControllerBase
    {
        private readonly ICartService _cartService;
        private readonly ILogger<CartController> _logger;
        private readonly IConfiguration _configuration;

        public CartController(ICartService cartService, ILogger<CartController> logger, IConfiguration configuration)
        {
            _cartService = cartService;
            _logger = logger;
            _configuration = configuration;
        }

        private int? GetEmployeeIdFromClaims()
        {
            var claim = User?.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            if (!int.TryParse(claim, out var userId)) return null;

            var db = HttpContext.RequestServices.GetService(typeof(SupermarketAPI.Data.AppDbContext)) as SupermarketAPI.Data.AppDbContext;
            if (db == null) return null;

            // Use raw SQL to avoid EF mapping mismatches with older DB schemas
            var email = User?.FindFirst(System.Security.Claims.ClaimTypes.Email)?.Value;
            if (string.IsNullOrEmpty(email)) return null;

            try
            {
                var connStr = _configuration.GetConnectionString("DefaultConnection");
                using var conn = new SqlConnection(connStr);
                if (conn.State != System.Data.ConnectionState.Open) conn.Open();

                // Try find existing employee by email
                using (var cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "SELECT Id FROM Employees WHERE Email = @email";
                    var p = cmd.CreateParameter(); p.ParameterName = "@email"; p.Value = email; cmd.Parameters.Add(p);
                    var res = cmd.ExecuteScalar();
                    if (res != null && int.TryParse(res.ToString(), out var existingId))
                    {
                        return existingId;
                    }
                }

                // Insert minimal employee row (UserId, Name, Email, Role) — Role default to Employee
                using (var cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "INSERT INTO Employees (UserId, Name, Email, Role) OUTPUT INSERTED.Id VALUES (@userId, @name, @email, @role)";
                    var p0 = cmd.CreateParameter(); p0.ParameterName = "@userId"; p0.Value = userId; cmd.Parameters.Add(p0);
                    var p1 = cmd.CreateParameter(); p1.ParameterName = "@name"; p1.Value = email; cmd.Parameters.Add(p1);
                    var p2 = cmd.CreateParameter(); p2.ParameterName = "@email"; p2.Value = email; cmd.Parameters.Add(p2);
                    var p3 = cmd.CreateParameter(); p3.ParameterName = "@role"; p3.Value = "Employee"; cmd.Parameters.Add(p3);
                    var id = cmd.ExecuteScalar();
                    if (id != null && int.TryParse(id.ToString(), out var newId))
                    {
                        return newId;
                    }
                }
            }
            catch
            {
                // fallback: return null if anything fails
            }

            return null;
        }

        [HttpGet]
        [Authorize]
        public IActionResult GetCart()
        {
            _logger.LogInformation("GetCart called. Authenticated: {IsAuthenticated}", User?.Identity?.IsAuthenticated);
            _logger.LogInformation("Claims: {Claims}", string.Join(',', User?.Claims?.Select(c => c.Type + '=' + c.Value) ?? new string[0]));
            var empId = GetEmployeeIdFromClaims();
            if (empId == null) return Unauthorized();
            var cart = _cartService.GetCartForEmployee(empId.Value);
            return Ok(cart);
        }

        [HttpPost("add")]
        [Authorize]
        public IActionResult AddItem([FromBody] AddCartItemDto dto)
        {
            _logger.LogInformation("AddItem called with dto: {@dto}", dto);
            _logger.LogInformation("Authenticated: {IsAuthenticated}", User?.Identity?.IsAuthenticated);
            _logger.LogInformation("Claims: {Claims}", string.Join(',', User?.Claims?.Select(c => c.Type + '=' + c.Value) ?? new string[0]));
            var empId = GetEmployeeIdFromClaims();
            if (empId == null) return Unauthorized();

            // Resolve product price via ProductService to ensure correct unit price
            var productService = HttpContext.RequestServices.GetService(typeof(IProductService)) as IProductService;
            if (productService == null) return StatusCode(500, new { success = false, message = "Product service unavailable" });

            var product = productService.GetByIdAsync(dto.ProductId).GetAwaiter().GetResult();
            if (product == null) return NotFound(new { success = false, message = "Product not found" });

            // Add to cart and persist the unit price
            _cartService.AddItem(empId.Value, dto, product.Price);
            var cart = _cartService.GetCartForEmployee(empId.Value);

            return Ok(new { success = true });
        }

        [HttpPost("remove")]
        [Authorize]
        public IActionResult RemoveItem([FromBody] RemoveCartItemDto dto)
        {
            var empId = GetEmployeeIdFromClaims();
            if (empId == null) return Unauthorized();
            _cartService.RemoveItem(empId.Value, dto.ProductId);
            return Ok(new { success = true });
        }
    }
}

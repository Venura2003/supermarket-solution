using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SupermarketAPI.Common.Exceptions;
using SupermarketAPI.DTOs;
using SupermarketAPI.Services;
using System.Security.Claims;
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;

namespace SupermarketAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class OrdersController : ControllerBase
    {
        private readonly IOrderService _service;
        private readonly ILogger<OrdersController> _logger;

        public OrdersController(IOrderService service, ILogger<OrdersController> logger)
        {
            _service = service;
            _logger = logger;
        }

        [HttpPost]
        [Authorize(Roles = "Cashier,Admin")]
        public async Task<IActionResult> CreateOrder([FromBody] CreateOrderDto dto)
        {
            if (dto.Items == null || dto.Items.Count == 0)
                return BadRequest(new { message = "Order must contain at least one item" });

            if (string.IsNullOrWhiteSpace(dto.PaymentMethod))
                return BadRequest(new { message = "Payment method is required" });

            try
            {
                var employeeId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
                if (employeeId == 0)
                    return Unauthorized(new { message = "Invalid employee ID" });

                var order = await _service.CreateOrderAsync(dto, employeeId);
                return CreatedAtAction(nameof(GetOrder), new { id = order.Id }, order);
            }
            catch (InvalidProductException ex)
            {
                _logger.LogWarning(ex.Message);
                return NotFound(new { message = ex.Message });
            }
            catch (InsufficientStockException ex)
            {
                _logger.LogWarning(ex.Message);
                return BadRequest(new { 
                    message = ex.Message, 
                    productId = ex.ProductId,
                    required = ex.RequiredQty,
                    available = ex.AvailableQty
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating order");
                return StatusCode(500, new { message = "Internal server error" });
            }
        }

        [HttpPost("{id}/refund-items")]
        public async Task<IActionResult> RefundOrderItems(int id, [FromBody] RefundRequestDto request)
        {
            try
            {
                var result = await _service.RefundOrderItemsAsync(id, request);
                if (!result) return NotFound(new { message = "Order not found or items invalid" });
                return Ok(new { message = "Order items refunded successfully" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("{id}/refund")]
        [Authorize(Roles = "Cashier,Admin")]
        public async Task<IActionResult> RefundOrder(int id)
        {
            try
            {
                var result = await _service.RefundOrderAsync(id);
                if (!result) return NotFound(new { message = "Order not found" });
                return Ok(new { message = "Order refunded successfully" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetOrder(int id)
        {
            var order = await _service.GetOrderByIdAsync(id);
            if (order == null) return NotFound();
            return Ok(order);
        }

        [HttpGet]
        public async Task<IActionResult> GetOrders([FromQuery] DateTime? startDate, 
            [FromQuery] DateTime? endDate,
            [FromQuery] string? paymentMethod = null,
            [FromQuery] string? status = null,
            [FromQuery] int pageNumber = 1,
            [FromQuery] int pageSize = 50)
        {
            var filter = new OrderFilterDto(startDate, endDate, paymentMethod, status, pageNumber, pageSize);
            var orders = await _service.GetOrdersAsync(filter);
            return Ok(orders);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin,Manager")]
        public async Task<IActionResult> CancelOrder(int id)
        {
            try
            {
                var result = await _service.CancelOrderAsync(id);
                if (!result) return NotFound();
                return NoContent();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error cancelling order");
                return StatusCode(500, new { message = "Internal server error" });
            }
        }

        [HttpGet("sales/daily")]
        [Authorize(Roles = "Admin,Manager")]
        public async Task<IActionResult> GetDailySalesTotal([FromQuery] DateTime? date = null)
        {
            date ??= DateTime.UtcNow.Date;
            var total = await _service.GetTotalSalesAsync(date.Value, date.Value.AddDays(1));
            var count = await _service.GetTotalOrdersAsync(date.Value, date.Value.AddDays(1));
            
            return Ok(new { date = date.Value.Date, totalSales = total, orderCount = count });
        }
    }
}

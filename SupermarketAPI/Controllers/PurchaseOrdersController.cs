using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using SupermarketAPI.DTOs;
using SupermarketAPI.Services;

namespace SupermarketAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class PurchaseOrdersController : ControllerBase
    {
        private readonly IPurchaseOrderService _service;
        private readonly ILogger<PurchaseOrdersController> _logger;

        public PurchaseOrdersController(IPurchaseOrderService service, ILogger<PurchaseOrdersController> logger)
        {
            _service = service;
            _logger = logger;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            try
            {
                var orders = await _service.GetAllAsync();
                return Ok(orders);
            }
            catch (System.Exception ex)
            {
                _logger.LogError(ex, "Failed to retrieve purchase orders");
                return StatusCode(500, new { message = "Failed to retrieve purchase orders" });
            }
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            try
            {
                var po = await _service.GetByIdAsync(id);
                if (po == null) return NotFound();
                return Ok(po);
            }
            catch (System.Exception ex)
            {
                _logger.LogError(ex, "Failed to retrieve purchase order {Id}", id);
                return StatusCode(500, new { message = "Failed to retrieve purchase order" });
            }
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreatePurchaseOrderDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            try
            {
                var po = await _service.CreateAsync(dto);
                return CreatedAtAction(nameof(GetById), new { id = po.Id }, po);
            }
            catch (System.Exception ex)
            {
                _logger.LogError(ex, "Failed to create purchase order");
                return StatusCode(500, new { message = ex.Message });
            }
        }

        [HttpPost("{id}/receive")]
        public async Task<IActionResult> Receive(int id)
        {
            try
            {
                var po = await _service.ReceiveOrderAsync(id);
                return Ok(po);
            }
            catch (System.Exception ex)
            {
                _logger.LogError(ex, "Failed to receive purchase order {Id}", id);
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}

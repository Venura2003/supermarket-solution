using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SupermarketAPI.DTOs;
using SupermarketAPI.Services;

namespace SupermarketAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Produces("application/json")]
    public class ProductsController : ControllerBase
    {
        private readonly IProductService _productService;
        private readonly ILogger<ProductsController> _logger;

        public ProductsController(IProductService productService, ILogger<ProductsController> logger)
        {
            _productService = productService;
            _logger = logger;
        }

        [HttpGet]
        [AllowAnonymous] // Temporarily allow anonymous access for testing
        public async Task<IActionResult> GetAll()
        {
            var products = await _productService.GetAllAsync();
            return Ok(products);
        }

        [HttpGet("{id}")]
        [Authorize]
        public async Task<IActionResult> Get(int id)
        {
            var product = await _productService.GetByIdAsync(id);
            if (product == null) return NotFound(new { message = "Product not found" });
            return Ok(product);
        }

        [HttpGet("barcode/{barcode}")]
        [AllowAnonymous]
        public async Task<IActionResult> GetByBarcode(string barcode)
        {
            var product = await _productService.GetByBarcodeAsync(barcode);
            if (product == null) return NotFound(new { message = "Product not found" });
            return Ok(product);
        }

        [HttpPost]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Create([FromBody] CreateProductDto dto)
        {
            _logger.LogInformation("POST /api/products received: {@dto}", dto);
            if (!ModelState.IsValid)
            {
                _logger.LogWarning("Invalid model state for product: {@ModelState}", ModelState);
                return BadRequest(new ApiResponse<object>
                {
                    Success = false,
                    Message = "Invalid product data.",
                    Errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage)
                });
            }

            try
            {
                var created = await _productService.CreateAsync(dto);
                _logger.LogInformation("Product saved to DB: {@created}", created);
                return StatusCode(201, new ApiResponse<ProductDto>
                {
                    Success = true,
                    Message = "Product created successfully.",
                    Data = created
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error saving product to DB");
                return StatusCode(500, new ApiResponse<object>
                {
                    Success = false,
                    Message = "Failed to create product.",
                    Errors = new[] { ex.Message }
                });
            }
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateProductDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var ok = await _productService.UpdateAsync(id, dto);
            if (!ok) return NotFound(new { message = "Product not found" });
            return NoContent();
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Delete(int id)
        {
            var ok = await _productService.DeleteAsync(id);
            if (!ok) return NotFound(new { message = "Product not found" });
            return NoContent();
        }
    }
}

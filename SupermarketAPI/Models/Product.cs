using System.ComponentModel.DataAnnotations;

namespace SupermarketAPI.Models
{
    public class Product
    {
        public int Id { get; set; }

        [Required(ErrorMessage = "Product name is required")]
        [StringLength(255, MinimumLength = 2, ErrorMessage = "Product name must be between 2 and 255 characters")]
        public string Name { get; set; } = string.Empty;

        public int? CategoryId { get; set; }
        public Category? Category { get; set; }

        [StringLength(128)]
        public string? Barcode { get; set; }

        [StringLength(1024)]
        [System.Text.Json.Serialization.JsonPropertyName("imageUrl")]
        public string? ImageUrl { get; set; }

        [Range(0.01, 999999.99, ErrorMessage = "Price must be between 0.01 and 999999.99")]
        public decimal Price { get; set; }

        [Range(0, 999999.99, ErrorMessage = "Cost price must be positive")]
        public decimal CostPrice { get; set; } = 0; // Default to 0 for existing products until updated

        [Range(0, int.MaxValue, ErrorMessage = "Stock must be greater than or equal to 0")]
        public int Stock { get; set; }

        public int LowStockThreshold { get; set; } = 5;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}

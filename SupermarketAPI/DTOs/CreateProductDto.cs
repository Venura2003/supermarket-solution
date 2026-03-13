using System.ComponentModel.DataAnnotations;

namespace SupermarketAPI.DTOs
{
    public class CreateProductDto
    {
        [Required]
        [StringLength(255)]
        public string Name { get; set; } = string.Empty;

        public int? CategoryId { get; set; }

        [StringLength(128)]
        public string? Barcode { get; set; }

        [StringLength(1024)]
        public string? ImageUrl { get; set; }

        [Required]
        public decimal Price { get; set; }

        [Required]
        public int Stock { get; set; }

        public int LowStockThreshold { get; set; } = 5;
    }
}

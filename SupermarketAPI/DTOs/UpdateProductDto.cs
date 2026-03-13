using System.ComponentModel.DataAnnotations;

namespace SupermarketAPI.DTOs
{
    public class UpdateProductDto
    {
        [StringLength(255)]
        public string? Name { get; set; }

        public int? CategoryId { get; set; }

        [StringLength(128)]
        public string? Barcode { get; set; }

        [StringLength(1024)]
        public string? ImageUrl { get; set; }

        public decimal? Price { get; set; }

        public int? Stock { get; set; }

        public int? LowStockThreshold { get; set; }
    }
}

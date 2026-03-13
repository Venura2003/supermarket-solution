using System.ComponentModel.DataAnnotations;

namespace SupermarketAPI.DTOs
{
    public class CreateSupplierDto
    {
        [Required]
        public string Name { get; set; } = string.Empty;
        public string? ContactNo { get; set; }
        public string? Address { get; set; }
    }

    public class CreateGRNItemDto
    {
        [Required]
        public int ProductId { get; set; }
        
        [Range(1, int.MaxValue)]
        public int Quantity { get; set; }
        
        [Range(0, double.MaxValue)]
        public decimal UnitCost { get; set; }
        
        // Optional: Update the product's selling price if desired
        public decimal? NewSellingPrice { get; set; }
    }

    public class CreateGRNDto
    {
        [Required]
        public int SupplierId { get; set; }
        public string? Notes { get; set; }
        public List<CreateGRNItemDto> Items { get; set; } = new List<CreateGRNItemDto>();
    }
    
    public class SupplierDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? ContactNo { get; set; }
        public string? Address { get; set; }
        public bool IsActive { get; set; }
    }
}

using System.ComponentModel.DataAnnotations;

namespace SupermarketAPI.DTOs
{
    public class SaleDto
    {
        public int Id { get; set; }
        public string SaleNo { get; set; } = string.Empty;
        public int EmployeeId { get; set; }
        public string? EmployeeName { get; set; }
        public DateTime SaleDate { get; set; }
        public decimal TotalAmount { get; set; }
        public decimal DiscountAmount { get; set; }
        public string PaymentMethod { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
        public string Notes { get; set; } = string.Empty;
        public List<SaleItemDto> Items { get; set; } = new();
        public DateTime CreatedAt { get; set; }
    }

    public class CreateSaleDto
    {
        [Required]
        [Range(0.01, double.MaxValue)]
        public decimal TotalAmount { get; set; }

        [Range(0, double.MaxValue)]
        public decimal DiscountAmount { get; set; } = 0;

        [Required]
        [StringLength(50)]
        public string PaymentMethod { get; set; } = "Cash";

        [StringLength(500)]
        public string Notes { get; set; } = string.Empty;

        [Required]
        [MinLength(1)]
        public List<CreateSaleItemDto> Items { get; set; } = new();
    }

    public class SaleItemDto
    {
        public int Id { get; set; }
        public int ProductId { get; set; }
        public string? ProductName { get; set; }
        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal Discount { get; set; }
        public decimal LineTotal { get; set; }
    }

    public class CreateSaleItemDto
    {
        [Required]
        public int ProductId { get; set; }

        [Required]
        [Range(1, int.MaxValue)]
        public int Quantity { get; set; }

        [Required]
        [Range(0.01, double.MaxValue)]
        public decimal UnitPrice { get; set; }

        [Range(0, double.MaxValue)]
        public decimal Discount { get; set; } = 0;

        [Required]
        [Range(0.01, double.MaxValue)]
        public decimal LineTotal { get; set; }
    }
}
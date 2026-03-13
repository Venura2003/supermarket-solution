using System.ComponentModel.DataAnnotations;

namespace SupermarketAPI.Models
{
    public class Sale
    {
        public int Id { get; set; }

        [Required]
        [StringLength(50)]
        public string SaleNo { get; set; } = string.Empty;

        public int EmployeeId { get; set; }
        public Employee? Employee { get; set; }

        public DateTime SaleDate { get; set; } = DateTime.UtcNow;

        [Range(0.01, double.MaxValue)]
        public decimal TotalAmount { get; set; }

        [Range(0, double.MaxValue)]
        public decimal DiscountAmount { get; set; } = 0;

        [Required]
        [StringLength(50)]
        public string PaymentMethod { get; set; } = "Cash";

        [Required]
        [StringLength(50)]
        public string Status { get; set; } = "Completed";

        [StringLength(500)]
        public string Notes { get; set; } = string.Empty;

        public ICollection<SaleItem> SaleItems { get; set; } = new List<SaleItem>();

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }
    }
}
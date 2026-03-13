using System.ComponentModel.DataAnnotations;
using SupermarketAPI.Common;

namespace SupermarketAPI.Models
{
    public class InventoryLog
    {
        public int Id { get; set; }

        public int ProductId { get; set; }
        public Product? Product { get; set; }

        [Required]
        [StringLength(50)]
        public string Action { get; set; } = InventoryAction.StockIn.ToString();

        [Range(1, int.MaxValue)]
        public int Quantity { get; set; }

        [StringLength(50)]
        public string Reason { get; set; } = string.Empty;

        public int? EmployeeId { get; set; }
        public Employee? Employee { get; set; }

        public DateTime Timestamp { get; set; } = DateTime.UtcNow;

        [StringLength(500)]
        public string Notes { get; set; } = string.Empty;
    }
}
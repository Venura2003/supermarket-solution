using System.ComponentModel.DataAnnotations;

namespace SupermarketAPI.Models
{
    public class SaleItem
    {
        public int Id { get; set; }

        public int SaleId { get; set; }
        public Sale? Sale { get; set; }

        public int ProductId { get; set; }
        public Product? Product { get; set; }

        [Range(1, int.MaxValue)]
        public int Quantity { get; set; }

        [Range(0.01, double.MaxValue)]
        public decimal UnitPrice { get; set; }

        [Range(0, double.MaxValue)]
        public decimal UnitCost { get; set; } // Cost price at the time of sale

        [Range(0, double.MaxValue)]
        public decimal Discount { get; set; } = 0;

        [Range(0.01, double.MaxValue)]
        public decimal LineTotal { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
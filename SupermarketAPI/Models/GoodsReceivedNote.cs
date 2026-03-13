using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SupermarketAPI.Models
{
    public class GoodsReceivedNote
    {
        public int Id { get; set; }

        public int SupplierId { get; set; }

        [ForeignKey("SupplierId")]
        public Supplier? Supplier { get; set; }

        public DateTime ReceivedDate { get; set; } = DateTime.UtcNow;

        [Column(TypeName = "decimal(18,2)")]
        public decimal TotalAmount { get; set; }

        [StringLength(500)]
        public string? Notes { get; set; }

        public ICollection<GoodsReceivedNoteItem> Items { get; set; } = new List<GoodsReceivedNoteItem>();
    }

    public class GoodsReceivedNoteItem
    {
        public int Id { get; set; }

        public int GoodsReceivedNoteId { get; set; }

        [ForeignKey("GoodsReceivedNoteId")]
        public GoodsReceivedNote? GoodsReceivedNote { get; set; }

        public int ProductId { get; set; }

        [ForeignKey("ProductId")]
        public Product? Product { get; set; }

        public int Quantity { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal UnitCost { get; set; }  // Cost Price per unit

        [Column(TypeName = "decimal(18,2)")]
        public decimal TotalCost { get; set; } // Quantity * UnitCost
    }
}

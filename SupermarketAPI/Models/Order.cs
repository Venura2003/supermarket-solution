using SupermarketAPI.Common;

namespace SupermarketAPI.Models
{
    public class Order
    {
        public int Id { get; set; }

        public string OrderNo { get; set; } = string.Empty;

        public int EmployeeId { get; set; }

        public Employee? Employee { get; set; }

        public DateTime OrderDate { get; set; } = DateTime.UtcNow;

        public decimal TotalAmount { get; set; }

        public decimal DiscountAmount { get; set; } = 0;

        public string PaymentMethod { get; set; } = "Cash";

        public string Status { get; set; } = OrderStatus.Pending.ToString();

        public string Notes { get; set; } = string.Empty;

        public ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? UpdatedAt { get; set; }
    }
}

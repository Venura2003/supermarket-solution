using System.ComponentModel.DataAnnotations;

namespace SupermarketAPI.DTOs
{
    public class CartItemDto
    {
        [Required]
        public int ProductId { get; set; }

        [Required]
        [Range(1, int.MaxValue)]
        public int Quantity { get; set; }

        [Required]
        public decimal UnitPrice { get; set; }

        public decimal Discount { get; set; } = 0;
    }

    public class CartDto
    {
        public List<CartItemDto> Items { get; set; } = new List<CartItemDto>();
        public decimal Discount { get; set; } = 0;

        public decimal Subtotal => Items.Sum(i => (i.UnitPrice - i.Discount) * i.Quantity);
        public decimal Total => Math.Max(0, Subtotal - Discount);
    }

    public class AddCartItemDto
    {
        [Required]
        public int ProductId { get; set; }

        [Required]
        [Range(1, int.MaxValue)]
        public int Quantity { get; set; }
    }

    public class RemoveCartItemDto
    {
        [Required]
        public int ProductId { get; set; }
    }
}

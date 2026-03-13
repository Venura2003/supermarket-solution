namespace SupermarketAPI.DTOs
{
    public class RefundRequestDto
    {
        public List<RefundItemDto> Items { get; set; } = new();
    }

    public class RefundItemDto
    {
        public int OrderItemId { get; set; }
        public int Quantity { get; set; }
    }
}

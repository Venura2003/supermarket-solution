using SupermarketAPI.DTOs;

namespace SupermarketAPI.Services
{
    public interface IOrderService
    {
        Task<OrderDto> CreateOrderAsync(CreateOrderDto dto, int employeeId);
        Task<OrderDto?> GetOrderByIdAsync(int id);
        Task<IEnumerable<OrderDto>> GetOrdersAsync(OrderFilterDto filter);
        Task<bool> CancelOrderAsync(int id);
        Task<bool> RefundOrderAsync(int id);
        Task<bool> RefundOrderItemsAsync(int orderId, RefundRequestDto request);
        Task<decimal> GetTotalSalesAsync(DateTime from, DateTime to);
        Task<int> GetTotalOrdersAsync(DateTime from, DateTime to);
        Task<string> GenerateReceiptAsync(int orderId);
    }
}

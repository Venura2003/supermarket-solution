using SupermarketAPI.DTOs;

namespace SupermarketAPI.Services
{
    public interface ICartService
    {
        CartDto GetCartForEmployee(int employeeId);
        void AddItem(int employeeId, AddCartItemDto item, decimal unitPrice);
        void RemoveItem(int employeeId, int productId);
        void ClearCart(int employeeId);
        // Persistence-aware methods
        Task<CartDto> GetCartForEmployeeAsync(int employeeId);
        Task AddItemAsync(int employeeId, AddCartItemDto item, decimal unitPrice);
        Task RemoveItemAsync(int employeeId, int productId);
        Task ClearCartAsync(int employeeId);
    }
}

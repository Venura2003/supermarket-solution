using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.DTOs;
using SupermarketAPI.Data;
using SupermarketAPI.Models;

namespace SupermarketAPI.Services
{
    // DB-backed cart service. Falls back to in-memory behavior if DB not available.
    public class CartService : ICartService
    {
        private readonly AppDbContext _db;
        private readonly ILogger<CartService>? _logger;

        public CartService(AppDbContext db)
        {
            _db = db;
        }

        public CartService(AppDbContext db, ILogger<CartService> logger)
        {
            _db = db;
            _logger = logger;
        }

        public CartDto GetCartForEmployee(int employeeId)
        {
            var cart = _db.Carts.FirstOrDefault(c => c.EmployeeId == employeeId);
            var cartDto = new CartDto();
            if (cart != null)
            {
                // Always fetch items from CartItems table to avoid navigation property issues
                var items = _db.CartItems.Where(i => i.CartId == cart.Id).ToList();
                cartDto.Items = items.Select(i => new CartItemDto
                {
                    ProductId = i.ProductId,
                    Quantity = i.Quantity,
                    UnitPrice = i.UnitPrice,
                    Discount = 0 // If you have discount logic, update here
                }).ToList();
            }
            return cartDto;
        }

        public async Task<CartDto> GetCartForEmployeeAsync(int employeeId)
        {
            var cart = await _db.Carts.Where(c => c.EmployeeId == employeeId)
                       .Select(c => new CartDto { Items = c.Items.Select(i => new CartItemDto { ProductId = i.ProductId, Quantity = i.Quantity, UnitPrice = i.UnitPrice }).ToList() })
                       .FirstOrDefaultAsync();

            return cart ?? new CartDto();
        }

        public void AddItem(int employeeId, AddCartItemDto item, decimal unitPrice)
        {
            // synchronous wrapper
            // synchronous wrapper with logging
            var task = AddItemAsync(employeeId, item, unitPrice);
            task.Wait();
        }

        public async Task AddItemAsync(int employeeId, AddCartItemDto item, decimal unitPrice)
        {

            // Logging: Start add item
            _logger?.LogInformation("AddItemAsync called for EmployeeId={EmployeeId}, ProductId={ProductId}, Quantity={Quantity}", employeeId, item.ProductId, item.Quantity);

            var cart = _db.Carts.FirstOrDefault(c => c.EmployeeId == employeeId);
            if (cart == null)
            {
                cart = new Cart { EmployeeId = employeeId };
                _db.Carts.Add(cart);
                await _db.SaveChangesAsync();
                _logger?.LogInformation("Cart created and saved for EmployeeId={EmployeeId}, CartId={CartId}", employeeId, cart.Id);
            }

                var existing = _db.CartItems.FirstOrDefault(ci => ci.CartId == cart.Id && ci.ProductId == item.ProductId);
                if (existing != null)
                {
                    existing.Quantity += item.Quantity;
                    // Update unit price as well in case it changed
                    existing.UnitPrice = unitPrice;
                    _logger?.LogInformation("CartItem updated: CartId={CartId}, ProductId={ProductId}, NewQuantity={Quantity}, UnitPrice={UnitPrice}", cart.Id, item.ProductId, existing.Quantity, existing.UnitPrice);
                }
                else
                {
                    _db.CartItems.Add(new CartItem { CartId = cart.Id, ProductId = item.ProductId, Quantity = item.Quantity, UnitPrice = unitPrice });
                    _logger?.LogInformation("CartItem added: CartId={CartId}, ProductId={ProductId}, Quantity={Quantity}, UnitPrice={UnitPrice}", cart.Id, item.ProductId, item.Quantity, unitPrice);
                }

                await _db.SaveChangesAsync();
                _logger?.LogInformation("Cart and items saved for EmployeeId={EmployeeId}, CartId={CartId}", employeeId, cart.Id);
        }

        public void RemoveItem(int employeeId, int productId)
        {
            RemoveItemAsync(employeeId, productId).GetAwaiter().GetResult();
        }

        public async Task RemoveItemAsync(int employeeId, int productId)
        {
            var cart = _db.Carts.FirstOrDefault(c => c.EmployeeId == employeeId);
            if (cart == null) return;

            var item = _db.CartItems.FirstOrDefault(ci => ci.CartId == cart.Id && ci.ProductId == productId);
            if (item != null)
            {
                _db.CartItems.Remove(item);
                await _db.SaveChangesAsync();
            }
        }

        public void ClearCart(int employeeId)
        {
            ClearCartAsync(employeeId).GetAwaiter().GetResult();
        }

        public async Task ClearCartAsync(int employeeId)
        {
            var cart = _db.Carts.FirstOrDefault(c => c.EmployeeId == employeeId);
            if (cart == null) return;
            var items = _db.CartItems.Where(ci => ci.CartId == cart.Id);
            _db.CartItems.RemoveRange(items);
            _db.Carts.Remove(cart);
            await _db.SaveChangesAsync();
        }
    }
}

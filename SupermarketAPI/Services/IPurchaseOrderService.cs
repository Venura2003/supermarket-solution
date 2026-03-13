using System.Collections.Generic;
using System.Threading.Tasks;
using SupermarketAPI.DTOs;

namespace SupermarketAPI.Services
{
    public interface IPurchaseOrderService
    {
        Task<IEnumerable<PurchaseOrderDto>> GetAllAsync();
        Task<PurchaseOrderDto> GetByIdAsync(int id);
        Task<PurchaseOrderDto> CreateAsync(CreatePurchaseOrderDto dto);
        Task<PurchaseOrderDto> ReceiveOrderAsync(int id);
    }
}

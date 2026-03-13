using SupermarketAPI.DTOs;
using SupermarketAPI.Models;

namespace SupermarketAPI.Services
{
    public interface ISaleService
    {
        Task<IEnumerable<SaleDto>> GetAllAsync();
        Task<SaleDto?> GetByIdAsync(int id);
        Task<SaleDto> CreateAsync(CreateSaleDto dto, int employeeId);
        Task<string> GenerateReceiptAsync(int saleId);
        Task<bool> UpdateStatusAsync(int id, string status);
        Task<IEnumerable<SaleDto>> GetByEmployeeAsync(int employeeId);
        Task<IEnumerable<SaleDto>> GetByDateRangeAsync(DateTime startDate, DateTime endDate);
    }
}
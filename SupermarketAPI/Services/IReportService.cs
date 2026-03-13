using System;
using System.Threading.Tasks;
using SupermarketAPI.DTOs;

namespace SupermarketAPI.Services
{
    public interface IReportService
    {
        Task<DailySalesReportDto> GetDailySalesAsync(DateTime date);
        Task<MonthlySalesReportDto> GetMonthlySalesAsync(int year, int month);
        Task<System.Collections.Generic.List<TopProductDto>> GetTopSellingProductsAsync(int limit);
        Task<ProfitSummaryDto> GetProfitSummaryAsync(DateTime? startDate, DateTime? endDate);
    }
}

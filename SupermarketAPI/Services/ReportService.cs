using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.DTOs;
using SupermarketAPI.Data;

namespace SupermarketAPI.Services
{
    public class ReportService : IReportService
    {
        private readonly AppDbContext _db;

        public ReportService(AppDbContext db)
        {
            _db = db;
        }

        public async Task<List<TopProductDto>> GetTopSellingProductsAsync(int limit)
        {
            var topProducts = await _db.OrderItems
                .Include(oi => oi.Product)
                .GroupBy(oi => new { oi.ProductId, Name = oi.Product != null ? oi.Product.Name : "Unknown" })
                .Select(g => new TopProductDto
                {
                    ProductId = g.Key.ProductId,
                    Name = g.Key.Name,
                    QuantitySold = g.Sum(oi => oi.Quantity),
                    Revenue = g.Sum(oi => oi.LineTotal) // Use LineTotal directly for accuracy
                })
                .OrderByDescending(tp => tp.QuantitySold)
                .Take(limit)
                .ToListAsync();

            return topProducts;
        }

        public async Task<DailySalesReportDto> GetDailySalesAsync(DateTime date)
        {
            var start = date.Date;
            var end = start.AddDays(1);

            var query = _db.Orders.Where(o => o.OrderDate >= start && o.OrderDate < end);

            var totalAmount = await query.SumAsync(o => (decimal?)o.TotalAmount) ?? 0m;
            // Use TotalAmount which is effectively final (Price + Tax - Discount)
            
            var totalOrders = await query.CountAsync();

            return new DailySalesReportDto
            {
                Date = start,
                TotalSalesAmount = totalAmount,
                TotalOrders = totalOrders
            };
        }

        public async Task<MonthlySalesReportDto> GetMonthlySalesAsync(int year, int month)
        {
            var start = new DateTime(year, month, 1);
            var end = start.AddMonths(1);

            var query = _db.Orders.Where(o => o.OrderDate >= start && o.OrderDate < end);

            var totalAmount = await query.SumAsync(o => (decimal?)o.TotalAmount) ?? 0m;
            var totalOrders = await query.CountAsync();

            return new MonthlySalesReportDto
            {
                Year = year,
                Month = month,
                TotalSalesAmount = totalAmount,
                TotalOrders = totalOrders
            };
        }

        public async Task<ProfitSummaryDto> GetProfitSummaryAsync(DateTime? startDate, DateTime? endDate)
        {
            var start = startDate ?? DateTime.MinValue;
            var end = endDate ?? DateTime.MaxValue;

            var salesQuery = _db.Orders.Where(o => o.OrderDate >= start && o.OrderDate <= end);
            var expensesQuery = _db.Expenses.Where(e => e.Date >= start && e.Date <= end);
            
            // Total Sales
            var totalSales = await salesQuery.SumAsync(o => (decimal?)o.TotalAmount) ?? 0m;
            
            // Total Product Cost (Simplified: Quantity * Current Cost)
            // Ideally we should track historical cost in OrderItems or SaleItems
            /* 
             * Since OrderItems doesn't have UnitCost in current context (it's not available in ICollection<OrderItem> unless included),
             * we need to query OrderItems separately
             */
             
            var costQuery = _db.OrderItems
                .Where(oi => oi.Order.OrderDate >= start && oi.Order.OrderDate <= end)
                .Select(oi => oi.Quantity * (decimal?)oi.Product.CostPrice ?? 0m);

            var totalProductCost = await costQuery.SumAsync();

            var totalExpenses = await expensesQuery.SumAsync(e => (decimal?)e.Amount) ?? 0m;

            return new ProfitSummaryDto
            {
                TotalSales = totalSales,
                TotalProductCost = totalProductCost,
                TotalExpenses = totalExpenses,
                NetProfit = totalSales - totalProductCost - totalExpenses
            };
        }
    }
}

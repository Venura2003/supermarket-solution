using System;

namespace SupermarketAPI.DTOs
{
    public class DailySalesReportDto
    {
        public DateTime Date { get; set; }
        public decimal TotalSalesAmount { get; set; }
        public int TotalOrders { get; set; }
    }

    public class MonthlySalesReportDto
    {
        public int Year { get; set; }
        public int Month { get; set; }
        public decimal TotalSalesAmount { get; set; }
        public int TotalOrders { get; set; }
    }

    public class TopProductDto
    {
        public int ProductId { get; set; }
        public string Name { get; set; } = string.Empty;
        public int QuantitySold { get; set; }
        public decimal Revenue { get; set; }
    }
}

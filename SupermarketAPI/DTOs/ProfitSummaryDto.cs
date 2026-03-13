namespace SupermarketAPI.DTOs
{
    public class ProfitSummaryDto
    {
        public decimal TotalSales { get; set; }
        public decimal TotalProductCost { get; set; }
        public decimal TotalExpenses { get; set; }
        public decimal NetProfit { get; set; }
    }
}

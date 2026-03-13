namespace SupermarketAPI.DTOs
{
    public class SalaryAdvanceDto
    {
        public int Id { get; set; }
        public int EmployeeId { get; set; }
        public decimal Amount { get; set; }
        public DateTime Date { get; set; }
        public string Note { get; set; } = string.Empty;
        public bool IsDeducted { get; set; }
    }

    public class CreateSalaryAdvanceDto
    {
        public int EmployeeId { get; set; }
        public decimal Amount { get; set; }
        public string Note { get; set; } = string.Empty;
        public DateTime Date { get; set; }
    }
}

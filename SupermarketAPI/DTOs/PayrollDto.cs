namespace SupermarketAPI.DTOs
{
    public class PayrollDto
    {
        public int Id { get; set; }
        public int EmployeeId { get; set; }
        public string EmployeeName { get; set; } = string.Empty;
        public string MonthYear { get; set; } = string.Empty;
        public DateTime PeriodStart { get; set; }
        public DateTime PeriodEnd { get; set; }
        public decimal BasicSalary { get; set; }
        public int WorkedDays { get; set; }
        public double OvertimeHours { get; set; }
        public decimal OvertimeRate { get; set; }
        public decimal Bonuses { get; set; }
        public decimal Advances { get; set; }
        public decimal OtherDeductions { get; set; }
        public decimal Epf8 { get; set; }
        public decimal Tax { get; set; }
        public decimal Epf12 { get; set; }
        public decimal Etf3 { get; set; }
        public decimal NetSalary { get; set; }
        public string Status { get; set; } = string.Empty;
        public DateTime GeneratedDate { get; set; }
    }

    public class CreatePayrollDto
    {
        public int EmployeeId { get; set; }
        public string MonthYear { get; set; } = string.Empty;
        public DateTime PeriodStart { get; set; }
        public DateTime PeriodEnd { get; set; }
        public decimal BasicSalary { get; set; }
        public int WorkedDays { get; set; }
        public double OvertimeHours { get; set; }
        public decimal OvertimeRate { get; set; }
        public decimal Bonuses { get; set; }
        public decimal Advances { get; set; }
        public decimal OtherDeductions { get; set; }
        public decimal Epf8 { get; set; }
        public decimal Tax { get; set; }
        public decimal Epf12 { get; set; }
        public decimal Etf3 { get; set; }
        public decimal NetSalary { get; set; }
    }
}

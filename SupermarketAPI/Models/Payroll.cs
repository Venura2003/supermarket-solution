using SupermarketAPI.Common;
using System.ComponentModel.DataAnnotations.Schema;

namespace SupermarketAPI.Models
{
    public class Payroll
    {
        public int Id { get; set; }

        public int EmployeeId { get; set; }
        [ForeignKey("EmployeeId")]
        public Employee? Employee { get; set; }

        public string MonthYear { get; set; } = string.Empty;

        public DateTime PeriodStart { get; set; }
        public DateTime PeriodEnd { get; set; }

        // Earnings
        [Column(TypeName = "decimal(18,2)")]
        public decimal BasicSalary { get; set; }
        
        public int WorkedDays { get; set; }
        
        public double OvertimeHours { get; set; }
        
        [Column(TypeName = "decimal(18,2)")]
        public decimal OvertimeRate { get; set; }
        
        [Column(TypeName = "decimal(18,2)")]
        public decimal Bonuses { get; set; }

        // Deductions
        [Column(TypeName = "decimal(18,2)")]
        public decimal Advances { get; set; }
        
        [Column(TypeName = "decimal(18,2)")]
        public decimal OtherDeductions { get; set; }
        
        [Column(TypeName = "decimal(18,2)")]
        public decimal Epf8 { get; set; }
        
        [Column(TypeName = "decimal(18,2)")]
        public decimal Tax { get; set; }

        // Employer Contributions
        [Column(TypeName = "decimal(18,2)")]
        public decimal Epf12 { get; set; }
        
        [Column(TypeName = "decimal(18,2)")]
        public decimal Etf3 { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal NetSalary { get; set; }

        public PayrollStatus Status { get; set; } = PayrollStatus.Draft;

        public DateTime GeneratedDate { get; set; } = DateTime.UtcNow;
    }
}

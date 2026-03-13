using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SupermarketAPI.Models
{
    public class SalaryAdvance
    {
        public int Id { get; set; }

        public int EmployeeId { get; set; }
        [ForeignKey("EmployeeId")]
        public Employee? Employee { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal Amount { get; set; }

        public DateTime Date { get; set; } = DateTime.UtcNow;

        [MaxLength(500)]
        public string Note { get; set; } = string.Empty;

        public bool IsDeducted { get; set; } = false;

        public int? PayrollId { get; set; }
        [ForeignKey("PayrollId")]
        public Payroll? Payroll { get; set; }
    }
}

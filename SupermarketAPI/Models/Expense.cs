using System.ComponentModel.DataAnnotations;

namespace SupermarketAPI.Models
{
    public class Expense
    {
        public int Id { get; set; }

        [Required]
        public string Description { get; set; } = string.Empty;

        [Required]
        [Range(0.01, double.MaxValue, ErrorMessage = "Amount must be greater than zero")]
        public decimal Amount { get; set; }

        public DateTime Date { get; set; } = DateTime.UtcNow;

        [Required]
        public string Category { get; set; } = string.Empty; // e.g., "Utility", "Rent", "Salary", "Maintenance", "Other"

        public string? CreatedBy { get; set; } // Username or Employee ID
    }
}

using System.ComponentModel.DataAnnotations;

namespace SupermarketAPI.DTOs
{
    public class ExpenseDto
    {
        public int Id { get; set; }
        public string Description { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public DateTime Date { get; set; }
        public string Category { get; set; } = string.Empty;
        public string? CreatedBy { get; set; }
    }

    public class CreateExpenseDto
    {
        [Required]
        public string Description { get; set; } = string.Empty;

        [Required]
        [Range(0.01, double.MaxValue, ErrorMessage = "Amount must be greater than zero")]
        public decimal Amount { get; set; }

        [Required]
        public string Category { get; set; } = string.Empty;

        public DateTime Date { get; set; } = DateTime.UtcNow; // Optional, default to now
    }
}

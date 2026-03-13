using System.ComponentModel.DataAnnotations;

namespace SupermarketAPI.Models
{
    public class Notification
    {
        public int Id { get; set; }

        [Required]
        [StringLength(255)]
        public string Title { get; set; } = string.Empty;

        [Required]
        [StringLength(1000)]
        public string Message { get; set; } = string.Empty;

        [Required]
        [StringLength(50)]
        public string Type { get; set; } = "Info"; // Info, Warning, Error, Success

        public bool IsRead { get; set; } = false;

        public int? EmployeeId { get; set; } // Null for global notifications
        public Employee? Employee { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
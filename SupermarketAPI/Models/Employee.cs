namespace SupermarketAPI.Models
{
    public class Employee
    {
        public int Id { get; set; }

        public int? UserId { get; set; }

        public User? User { get; set; }

        public string Name { get; set; } = string.Empty;

        public string Email { get; set; } = string.Empty;

        public string Phone { get; set; } = string.Empty;

        public string Position { get; set; } = string.Empty;

        public decimal? Salary { get; set; }

        public DateTime? HireDate { get; set; } = DateTime.UtcNow;

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? UpdatedAt { get; set; }

        public ICollection<Order> Orders { get; set; } = new List<Order>();

    }
}

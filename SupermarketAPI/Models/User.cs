using System.ComponentModel.DataAnnotations;

namespace SupermarketAPI.Models
{
    public class User
    {
        public int Id { get; set; }

        [Required(ErrorMessage = "Email is required")]
        [EmailAddress(ErrorMessage = "Invalid email address")]
        [StringLength(255)]
        public string Email { get; set; } = string.Empty;

        [StringLength(100)]
        public string? Username { get; set; }

        [Required(ErrorMessage = "Password hash is required")]
        public string PasswordHash { get; set; } = string.Empty;

        [Required(ErrorMessage = "Role is required")]
        [StringLength(50)]
        public string Role { get; set; } = UserRoles.Employee;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public bool IsActive { get; set; } = true;
    }

    public static class UserRoles
    {
        public const string Admin = "Admin";
        public const string Employee = "Employee";

        public static bool IsValidRole(string role)
        {
            return role == Admin || role == Employee;
        }
    }
}

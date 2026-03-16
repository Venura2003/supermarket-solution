using System.ComponentModel.DataAnnotations;

namespace SupermarketAPI.Models.DTOs
{
    public class ProductDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public decimal Price { get; set; }
        public int Quantity { get; set; }
    }

    public class CreateProductDto
    {
        [Required(ErrorMessage = "Product name is required")]
        [StringLength(255, MinimumLength = 2, ErrorMessage = "Product name must be between 2 and 255 characters")]
        public string Name { get; set; } = string.Empty;

        [Range(0.01, 999999.99, ErrorMessage = "Price must be between 0.01 and 999999.99")]
        public decimal Price { get; set; }

        [Range(0, int.MaxValue, ErrorMessage = "Quantity must be greater than or equal to 0")]
        public int Quantity { get; set; }
    }

    public class UpdateProductDto
    {
        [StringLength(255, MinimumLength = 2, ErrorMessage = "Product name must be between 2 and 255 characters")]
        public string? Name { get; set; }

        [Range(0.01, 999999.99, ErrorMessage = "Price must be between 0.01 and 999999.99")]
        public decimal? Price { get; set; }

        [Range(0, int.MaxValue, ErrorMessage = "Quantity must be greater than or equal to 0")]
        public int? Quantity { get; set; }
    }

    public class LoginRequest
    {
        // The frontend must send the identifier (email or username) in the 'Email' field for compatibility.
        [Required(ErrorMessage = "Identifier (email or username) is required")]
        public string Email { get; set; } = string.Empty;

        [Required(ErrorMessage = "Password is required")]
        [StringLength(255, MinimumLength = 6, ErrorMessage = "Password must be at least 6 characters long")]
        public string Password { get; set; } = string.Empty;
    }

    public class RegisterRequest
    {
        [Required(ErrorMessage = "Email is required")]
        [EmailAddress(ErrorMessage = "Invalid email address")]
        public string Email { get; set; } = string.Empty;

        [StringLength(100)]
        public string? Username { get; set; }

        [Required(ErrorMessage = "Password is required")]
        [StringLength(255, MinimumLength = 6, ErrorMessage = "Password must be at least 6 characters long")]
        public string Password { get; set; } = string.Empty;

        [Required(ErrorMessage = "Role is required")]
        public string Role { get; set; } = UserRoles.Employee;
    }

    public class TokenResponse
    {
        public string AccessToken { get; set; } = string.Empty;
        public int UserId { get; set; }
        public DateTime ExpiresAt { get; set; }
        public string TokenType { get; set; } = "Bearer";
        public string Email { get; set; } = string.Empty;
        public string Role { get; set; } = string.Empty;
        public string? Username { get; set; }
    }

    public class AuthResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; } = string.Empty;
        public TokenResponse? Token { get; set; }
        public TokenResponse? Data { get; set; }
    }
}

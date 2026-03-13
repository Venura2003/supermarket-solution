using System.IdentityModel.Tokens.Jwt;
using System.Security.Cryptography;
using System.Text;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using SupermarketAPI.Common;
using SupermarketAPI.Data;
using SupermarketAPI.Models;
using SupermarketAPI.Models.DTOs;

namespace SupermarketAPI.Services
{
    public interface IAuthService
    {
        Task<TokenResponse> LoginAsync(LoginRequest request);
        Task<User> RegisterAsync(RegisterRequest request, string requestingUserRole);
        Task<int> GetUserCountAsync();
        Task SeedDefaultAdminAsync();
        TokenResponse GenerateToken(User user);
        bool VerifyPassword(string password, string hash);
        string HashPassword(string password);
        Task ChangePasswordAsync(int userId, string newPassword);
    }

    public class AuthService : IAuthService
    {
        private readonly AppDbContext _context;
        private readonly IConfiguration _configuration;
        private readonly ILogger<AuthService> _logger;
        private readonly PasswordHasher<User> _passwordHasher;

        public AuthService(AppDbContext context, IConfiguration configuration, ILogger<AuthService> logger)
        {
            _context = context;
            _configuration = configuration;
            _logger = logger;
            _passwordHasher = new PasswordHasher<User>();
        }

        public async Task<TokenResponse> LoginAsync(LoginRequest request)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
                    throw new ArgumentException("Identifier and password are required");

                var identifier = request.Email.Trim();

                // allow login by email or username
                var user = await _context.Users.FirstOrDefaultAsync(u =>
                    (!string.IsNullOrEmpty(u.Email) && u.Email.ToLower() == identifier.ToLower()) ||
                    (!string.IsNullOrEmpty(u.Username) && u.Username.ToLower() == identifier.ToLower())
                );

                if (user == null || !user.IsActive)
                    throw new UnauthorizedAccessException("Invalid credentials");

                if (!VerifyPassword(request.Password, user.PasswordHash))
                    throw new UnauthorizedAccessException("Invalid credentials");

                _logger.LogInformation("User {Email} logged in successfully", user.Email);
                return GenerateToken(user);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during login for email: {Email}", request.Email);
                throw;
            }
        }

        public async Task<User> RegisterAsync(RegisterRequest request, string requestingUserRole)
        {
            try
            {
                // Check if this is the first user registration
                var userCount = await _context.Users.CountAsync();
                
                // Only admins can register new users (except for the first user)
                if (userCount > 0 && requestingUserRole != UserRoles.Admin)
                    throw new UnauthorizedAccessException("Only administrators can register new users");

                if (!UserRoles.IsValidRole(request.Role))
                    throw new ArgumentException($"Invalid role. Valid roles are: {UserRoles.Admin}, {UserRoles.Employee}");

                var existingUserByEmail = await _context.Users.FirstOrDefaultAsync(u => u.Email.ToLower() == request.Email.ToLower());
                if (existingUserByEmail != null)
                    throw new InvalidOperationException("User with this email already exists");

                if (!string.IsNullOrWhiteSpace(request.Username))
                {
                    var existingByUsername = await _context.Users.FirstOrDefaultAsync(u => u.Username != null && u.Username.ToLower() == request.Username.ToLower());
                    if (existingByUsername != null)
                        throw new InvalidOperationException("User with this username already exists");
                }

                var user = new User
                {
                    Email = request.Email.ToLower().Trim(),
                    Username = string.IsNullOrWhiteSpace(request.Username) ? null : request.Username.Trim(),
                    PasswordHash = HashPassword(request.Password),
                    Role = request.Role,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                };

                _context.Users.Add(user);
                await _context.SaveChangesAsync();

                _logger.LogInformation("New user registered with email: {Email}, role: {Role}", user.Email, user.Role);
                return user;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during registration for email: {Email}", request.Email);
                throw;
            }
        }

        public TokenResponse GenerateToken(User user)
        {
            try
            {
                var jwtSettings = _configuration.GetSection("JwtSettings");
                var secretKey = jwtSettings["SecretKey"] ?? throw new InvalidOperationException("JWT secret key not configured");
                var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey));
                var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

                var expirationMinutes = int.Parse(jwtSettings["ExpirationMinutes"] ?? "60");
                var expiresAt = DateTime.UtcNow.AddMinutes(expirationMinutes);

                var claims = new List<System.Security.Claims.Claim>
                {
                    new System.Security.Claims.Claim(System.Security.Claims.ClaimTypes.NameIdentifier, user.Id.ToString()),
                    new System.Security.Claims.Claim(System.Security.Claims.ClaimTypes.Email, user.Email),
                    new System.Security.Claims.Claim(System.Security.Claims.ClaimTypes.Role, user.Role)
                };

                var token = new JwtSecurityToken(
                    issuer: jwtSettings["Issuer"],
                    audience: jwtSettings["Audience"],
                    claims: claims,
                    expires: expiresAt,
                    signingCredentials: credentials
                );

                var accessToken = new JwtSecurityTokenHandler().WriteToken(token);

                _logger.LogInformation("JWT token generated for user: {Email}", user.Email);

                return new TokenResponse
                {
                    AccessToken = accessToken,
                    UserId = user.Id,
                    ExpiresAt = expiresAt,
                    TokenType = "Bearer",
                    Email = user.Email,
                    Role = user.Role,
                    Username = user.Username
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error generating JWT token for user: {Email}", user.Email);
                throw;
            }
        }

        public bool VerifyPassword(string password, string hash)
        {
            // Use ASP.NET Core PasswordHasher for password verification
            var dummyUser = new User();
            var result = _passwordHasher.VerifyHashedPassword(dummyUser, hash, password);
            return result == PasswordVerificationResult.Success;
        }

        public string HashPassword(string password)
        {
            var user = new User();
            return _passwordHasher.HashPassword(user, password);
        }

        public async Task ChangePasswordAsync(int userId, string newPassword)
        {
            try
            {
                var user = await _context.Users.FindAsync(userId);
                if (user == null)
                    throw new KeyNotFoundException($"User with ID {userId} not found");

                user.PasswordHash = HashPassword(newPassword);
                _context.Users.Update(user);
                await _context.SaveChangesAsync();

                _logger.LogInformation("Password changed successfully for user ID: {UserId}", userId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error changing password for user ID: {UserId}", userId);
                throw;
            }
        }

        public async Task<int> GetUserCountAsync()
        {
            return await _context.Users.CountAsync();
        }

        public async Task SeedDefaultAdminAsync()
        {
            try
            {
                var adminUser = await _context.Users.FirstOrDefaultAsync(u => u.Email == "admin@gmail.com");
                if (adminUser == null)
                {
                    adminUser = new User
                    {
                        Email = "admin@gmail.com",
                        Username = "admin",
                        PasswordHash = HashPassword("123456"),
                        Role = UserRoles.Admin,
                        IsActive = true,
                        CreatedAt = DateTime.UtcNow
                    };

                    _context.Users.Add(adminUser);
                    await _context.SaveChangesAsync();

                    _logger.LogInformation("Default admin user seeded: {Email}", adminUser.Email);
                }
                else
                {
                    // Update password in case hashing changed
                    adminUser.PasswordHash = HashPassword("123456");
                    adminUser.Username = "admin";
                    adminUser.Role = UserRoles.Admin;
                    adminUser.IsActive = true;
                    await _context.SaveChangesAsync();

                    _logger.LogInformation("Default admin user updated: {Email}", adminUser.Email);
                }

                // Seed default cashier user
                var cashierUser = await _context.Users.FirstOrDefaultAsync(u => u.Email == "cashier@gmail.com");
                if (cashierUser == null)
                {
                    cashierUser = new User
                    {
                        Email = "cashier@gmail.com",
                        Username = "cashier",
                        PasswordHash = HashPassword("123456"),
                        Role = UserRoles.Employee,
                        IsActive = true,
                        CreatedAt = DateTime.UtcNow
                    };

                    _context.Users.Add(cashierUser);
                    await _context.SaveChangesAsync();

                    _logger.LogInformation("Default cashier user seeded: {Email}", cashierUser.Email);
                }
                else
                {
                    cashierUser.PasswordHash = HashPassword("123456");
                    cashierUser.Username = "cashier";
                    cashierUser.Role = UserRoles.Employee;
                    cashierUser.IsActive = true;
                    await _context.SaveChangesAsync();

                    _logger.LogInformation("Default cashier user updated: {Email}", cashierUser.Email);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error seeding default admin or cashier user");
                throw;
            }
        }
    }
}

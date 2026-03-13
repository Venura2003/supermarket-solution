using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SupermarketAPI.Models;
using SupermarketAPI.Models.DTOs;
using SupermarketAPI.Services;

namespace SupermarketAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Produces("application/json")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;
        private readonly ILogger<AuthController> _logger;

        public AuthController(IAuthService authService, ILogger<AuthController> logger)
        {
            _authService = authService;
            _logger = logger;
        }

        /// <summary>
        /// Login with email and password to receive JWT token
        /// </summary>
        /// <param name="request">Email and password</param>
        /// <returns>JWT token response (200 OK) or authentication error</returns>
        [HttpPost("login")]
        [AllowAnonymous]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<ActionResult<TokenResponse>> Login([FromBody] LoginRequest request)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                var tokenResponse = await _authService.LoginAsync(request);
                _logger.LogInformation("User {Email} successfully authenticated", request.Email);

                return Ok(tokenResponse);
            }
            catch (UnauthorizedAccessException ex)
            {
                _logger.LogWarning("Failed login attempt for email: {Email} - {Message}", request.Email, ex.Message);
                return Unauthorized(new { message = ex.Message });
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning("Invalid login request - {Message}", ex.Message);
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during login for email: {Email}", request.Email);
                throw;
            }
        }

        /// <summary>
        /// Register a new user (Admin only, except for the first user)
        /// </summary>
        /// <param name="request">User email, password, and role</param>
        /// <returns>Success message (201 Created)</returns>
        [HttpPost("register")]
        [AllowAnonymous]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        public async Task<ActionResult<object>> Register([FromBody] RegisterRequest request)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                // Allow first user registration without authentication
                var userCount = await _authService.GetUserCountAsync();
                var userRole = userCount == 0 ? UserRoles.Admin : (User.FindFirst(System.Security.Claims.ClaimTypes.Role)?.Value ?? UserRoles.Employee);
                var user = await _authService.RegisterAsync(request, userRole);

                _logger.LogInformation("New user registered with email: {Email}", request.Email);

                return CreatedAtAction(nameof(Register), new { email = user.Email },
                    new { message = "User registered successfully", userId = user.Id, email = user.Email, role = user.Role });
            }
            catch (UnauthorizedAccessException ex)
            {
                _logger.LogWarning("Unauthorized registration attempt - {Message}", ex.Message);
                return Forbid();
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning("Invalid registration request - {Message}", ex.Message);
                return BadRequest(new { message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogWarning("Registration error - {Message}", ex.Message);
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during registration for email: {Email}", request.Email);
                throw;
            }
        }

        /// <summary>
        /// Get current user info from JWT token
        /// </summary>
        /// <returns>Current user information</returns>
        [HttpGet("me")]
        [Authorize]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public ActionResult<object> GetCurrentUser()
        {
            try
            {
                var userId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
                var email = User.FindFirst(System.Security.Claims.ClaimTypes.Email)?.Value;
                var role = User.FindFirst(System.Security.Claims.ClaimTypes.Role)?.Value;

                if (string.IsNullOrEmpty(userId) || string.IsNullOrEmpty(email))
                {
                    return Unauthorized(new { message = "Invalid or expired token" });
                }

                return Ok(new
                {
                    userId = int.Parse(userId),
                    email,
                    role
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving current user info");
                throw;
            }
        }

        /// <summary>
        /// Change password for a user (Admin only)
        /// </summary>
        /// <param name="request.UserId">User ID</param>
        /// <param name="request.NewPassword">New Password</param>
        /// <returns>Success message (200 OK)</returns>
        [HttpPost("change-password")]
        [Authorize(Roles = UserRoles.Admin)] 
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest request)
        {
            try
            {
                await _authService.ChangePasswordAsync(request.UserId, request.NewPassword);
                return Ok(new { message = "Password changed successfully" });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error changing password for user ID: {UserId}", request.UserId);
                return StatusCode(500, new { message = "An error occurred while changing the password" });
            }
        }
    }
}

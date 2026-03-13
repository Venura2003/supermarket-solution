using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Common.Exceptions;
using SupermarketAPI.Data;
using SupermarketAPI.DTOs;
using SupermarketAPI.Models;

namespace SupermarketAPI.Services
{
    public class EmployeeService : IEmployeeService
    {
        private readonly AppDbContext _db;
        private readonly ILogger<EmployeeService> _logger;

        public EmployeeService(AppDbContext db, ILogger<EmployeeService> logger)
        {
            _db = db;
            _logger = logger;
        }

        public async Task<EmployeeDto> CreateEmployeeAsync(CreateEmployeeDto dto)
        {
            // Check if email already exists
            var existing = await _db.Employees
                .FirstOrDefaultAsync(e => e.Email.ToLower() == dto.Email.ToLower());

            if (existing != null)
            {
                throw new EmployeeException($"Employee with email {dto.Email} already exists");
            }

            // Validate UserId if provided
            User? user = null;
            if (dto.UserId.HasValue)
            {
                user = await _db.Users.FirstOrDefaultAsync(u => u.Id == dto.UserId.Value);
                if (user == null)
                {
                    throw new EmployeeException($"User with id {dto.UserId} does not exist");
                }
            }

            var employee = new Employee
            {
                UserId = dto.UserId,
                User = user, // Set the navigation property so MapToDto can use it
                Name = dto.Name,
                Email = dto.Email,
                Phone = dto.Phone,
                Position = dto.Position,
                Salary = dto.Salary,
                HireDate = dto.HireDate,
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            };

            await _db.Employees.AddAsync(employee);
            try
            {
                await _db.SaveChangesAsync();
            }
            catch (Microsoft.EntityFrameworkCore.DbUpdateException dbEx)
            {
                // Pragmatic fallback: try a raw SQL insert for minimal required fields
                _logger.LogWarning(dbEx, "EF SaveChanges failed for Employee insert, attempting raw SQL fallback");

                try
                {
                    // Use parameterized interpolated SQL to avoid injection
                    await _db.Database.ExecuteSqlInterpolatedAsync($@"INSERT INTO Employees
                        (UserId, Name, Email, Phone, Position, Salary, HireDate, IsActive, CreatedAt)
                        VALUES ({dto.UserId}, {dto.Name}, {dto.Email}, {dto.Phone}, {dto.Position}, {dto.Salary}, {dto.HireDate}, {true}, {DateTime.UtcNow})");

                    // Try to re-query the inserted employee by email
                    var inserted = await _db.Employees.FirstOrDefaultAsync(e => e.Email.ToLower() == dto.Email.ToLower());
                    if (inserted == null)
                    {
                        _logger.LogError("Raw SQL fallback completed but inserted employee could not be retrieved");
                        throw;
                    }

                    _logger.LogInformation($"Employee created via raw SQL fallback: {inserted.Name} ({inserted.Email})");
                    return MapToDto(inserted);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Raw SQL fallback also failed when creating employee");
                    throw; // bubble up original error
                }
            }

            _logger.LogInformation($"Employee created: {employee.Name} ({employee.Email})");

            return MapToDto(employee);
        }

        public async Task<EmployeeDto?> GetEmployeeByIdAsync(int id)
        {
            var employee = await _db.Employees
                .Include(e => e.User)
                .FirstOrDefaultAsync(e => e.Id == id);

            if (employee == null)
                return null;

            return MapToDto(employee);
        }

        public async Task<IEnumerable<EmployeeDto>> GetEmployeesAsync(EmployeeFilterDto filter)
        {
            var query = _db.Employees.Include(e => e.User).AsQueryable();

            if (filter.IsActive.HasValue)
                query = query.Where(e => e.IsActive == filter.IsActive);

            var employees = await query
                .OrderBy(e => e.Name)
                .Skip((filter.PageNumber - 1) * filter.PageSize)
                .Take(filter.PageSize)
                .ToListAsync();

            return employees.Select(MapToDto);
        }

        public async Task<bool> UpdateEmployeeAsync(int id, UpdateEmployeeDto dto)
        {
            var employee = await _db.Employees
                .FirstOrDefaultAsync(e => e.Id == id);

            if (employee == null)
                return false;

            // Check if new email conflicts with another employee
            if (employee.Email != dto.Email)
            {
                var conflict = await _db.Employees
                    .FirstOrDefaultAsync(e => e.Id != id && e.Email.ToLower() == dto.Email.ToLower());

                if (conflict != null)
                {
                    throw new EmployeeException($"Email {dto.Email} is already in use");
                }
            }

            employee.Name = dto.Name;
            employee.Email = dto.Email;
            employee.Phone = dto.Phone;
            employee.Position = dto.Position;
            employee.Salary = dto.Salary;
            employee.IsActive = dto.IsActive;
            
            if (dto.UserId.HasValue) 
            {
               employee.UserId = dto.UserId.Value;
            }
            
            employee.UpdatedAt = DateTime.UtcNow;

            _db.Employees.Update(employee);
            await _db.SaveChangesAsync();

            _logger.LogInformation($"Employee updated: {employee.Name} ({employee.Email})");

            return true;
        }

        public async Task<bool> DeleteEmployeeAsync(int id)
        {
            var employee = await _db.Employees
                .FirstOrDefaultAsync(e => e.Id == id);

            if (employee == null)
                return false;

            // Soft delete: set IsActive to false instead of removing from DB
            employee.IsActive = false;
            employee.UpdatedAt = DateTime.UtcNow;

            _db.Employees.Update(employee);
            await _db.SaveChangesAsync();

            _logger.LogInformation($"Employee deleted (soft): {employee.Name}");

            return true;
        }

        public async Task<EmployeeDto?> GetEmployeeByUserIdOrEmailAsync(int? userId, string? email)
        {
            if (userId == null && string.IsNullOrEmpty(email)) return null;

            Employee? emp = null;

            if (userId.HasValue)
            {
                emp = await _db.Employees
                    .Include(e => e.User)
                    .FirstOrDefaultAsync(e => e.UserId == userId.Value);
            }

            if (emp == null && !string.IsNullOrEmpty(email))
            {
                emp = await _db.Employees
                    .Include(e => e.User)
                    .FirstOrDefaultAsync(e => e.Email.ToLower() == email.ToLower());
            }

            return emp != null ? MapToDto(emp) : null;
        }

        private EmployeeDto MapToDto(Employee employee)
        {
            return new EmployeeDto(
                employee.Id,
                employee.UserId,
                employee.Name ?? "Unknown",
                employee.Email ?? "",
                employee.Phone ?? "",
                employee.Position ?? "",
                employee.Salary ?? 0m,
                employee.HireDate ?? DateTime.MinValue,
                // Return Position as Role if it matches our expected roles, otherwise fallback to User Role
                !string.IsNullOrWhiteSpace(employee.Position) && 
                (employee.Position == "Manager" || employee.Position == "Cashier" || employee.Position == "Admin" || employee.Position == "Employee") 
                    ? employee.Position 
                    : (employee.User?.Role ?? "Employee"),
                employee.User?.Username,
                employee.IsActive,
                employee.CreatedAt
            );
        }
    }
}

using SupermarketAPI.DTOs;

namespace SupermarketAPI.Services
{
    public interface IEmployeeService
    {
        Task<EmployeeDto> CreateEmployeeAsync(CreateEmployeeDto dto);
        Task<EmployeeDto?> GetEmployeeByIdAsync(int id);
        Task<IEnumerable<EmployeeDto>> GetEmployeesAsync(EmployeeFilterDto filter);
        Task<bool> UpdateEmployeeAsync(int id, UpdateEmployeeDto dto);
        Task<bool> DeleteEmployeeAsync(int id);
        Task<EmployeeDto?> GetEmployeeByUserIdOrEmailAsync(int? userId, string? email);
    }
}

using SupermarketAPI.DTOs;
using SupermarketAPI.Models;

namespace SupermarketAPI.Services
{
    public interface IPayrollService
    {
        Task<SalaryAdvance> CreateAdvanceAsync(CreateSalaryAdvanceDto dto);
        Task<IEnumerable<SalaryAdvanceDto>> GetPendingAdvancesAsync(int employeeId);
        Task<Payroll> CreatePayrollAsync(CreatePayrollDto dto);
        Task<IEnumerable<PayrollDto>> GetPayrollHistoryAsync();
        Task<IEnumerable<PayrollDto>> GetEmployeePayrollHistoryAsync(int employeeId);
    }
}

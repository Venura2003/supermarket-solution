using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Common;
using SupermarketAPI.Data;
using SupermarketAPI.DTOs;
using SupermarketAPI.Models;

namespace SupermarketAPI.Services
{
    public class PayrollService : IPayrollService
    {
        private readonly AppDbContext _context;

        public PayrollService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<SalaryAdvance> CreateAdvanceAsync(CreateSalaryAdvanceDto dto)
        {
            var advance = new SalaryAdvance
            {
                EmployeeId = dto.EmployeeId,
                Amount = dto.Amount,
                Date = dto.Date, // UTC assumed or exact moment
                Note = dto.Note,
                IsDeducted = false
            };
            
            _context.SalaryAdvances.Add(advance);
            await _context.SaveChangesAsync();
            return advance;
        }

        public async Task<IEnumerable<SalaryAdvanceDto>> GetPendingAdvancesAsync(int employeeId)
        {
            return await _context.SalaryAdvances
                .Where(a => a.EmployeeId == employeeId && !a.IsDeducted)
                .Select(a => new SalaryAdvanceDto
                {
                    Id = a.Id,
                    EmployeeId = a.EmployeeId,
                    Amount = a.Amount,
                    Date = a.Date,
                    Note = a.Note,
                    IsDeducted = a.IsDeducted
                })
                .ToListAsync();
        }

        public async Task<Payroll> CreatePayrollAsync(CreatePayrollDto dto)
        {
            var payroll = new Payroll
            {
                EmployeeId = dto.EmployeeId,
                MonthYear = dto.MonthYear,
                PeriodStart = dto.PeriodStart,
                PeriodEnd = dto.PeriodEnd,
                BasicSalary = dto.BasicSalary,
                WorkedDays = dto.WorkedDays,
                OvertimeHours = dto.OvertimeHours,
                OvertimeRate = dto.OvertimeRate,
                Bonuses = dto.Bonuses,
                Advances = dto.Advances,
                OtherDeductions = dto.OtherDeductions,
                Epf8 = dto.Epf8,
                Tax = dto.Tax,
                Epf12 = dto.Epf12,
                Etf3 = dto.Etf3,
                NetSalary = dto.NetSalary,
                Status = PayrollStatus.Draft,
                GeneratedDate = DateTime.UtcNow
            };

            _context.Payrolls.Add(payroll);

            // Mark advances as deducted (simplified logic: all pending up to period end)
            var pendingAdvances = await _context.SalaryAdvances
                .Where(a => a.EmployeeId == dto.EmployeeId && !a.IsDeducted && a.Date <= dto.PeriodEnd)
                .ToListAsync();

            foreach (var advance in pendingAdvances)
            {
                advance.IsDeducted = true;
                advance.Payroll = payroll;
            }

            await _context.SaveChangesAsync();
            return payroll;
        }

        public async Task<IEnumerable<PayrollDto>> GetPayrollHistoryAsync()
        {
            return await _context.Payrolls
                .Include(p => p.Employee)
                .OrderByDescending(p => p.GeneratedDate)
                .Select(p => new PayrollDto
                {
                    Id = p.Id,
                    EmployeeId = p.EmployeeId,
                    EmployeeName = p.Employee != null ? p.Employee.Name : "Unknown",
                    MonthYear = p.MonthYear,
                    PeriodStart = p.PeriodStart,
                    PeriodEnd = p.PeriodEnd,
                    BasicSalary = p.BasicSalary,
                    WorkedDays = p.WorkedDays,
                    OvertimeHours = p.OvertimeHours,
                    OvertimeRate = p.OvertimeRate,
                    Bonuses = p.Bonuses,
                    Advances = p.Advances,
                    OtherDeductions = p.OtherDeductions,
                    Epf8 = p.Epf8,
                    Tax = p.Tax,
                    Epf12 = p.Epf12,
                    Etf3 = p.Etf3,
                    NetSalary = p.NetSalary,
                    Status = p.Status.ToString(),
                    GeneratedDate = p.GeneratedDate
                })
                .ToListAsync();
        }

        public async Task<IEnumerable<PayrollDto>> GetEmployeePayrollHistoryAsync(int employeeId)
        {
            return await _context.Payrolls
                .Include(p => p.Employee)
                .Where(p => p.EmployeeId == employeeId)
                .OrderByDescending(p => p.GeneratedDate)
                .Select(p => new PayrollDto
                {
                    Id = p.Id,
                    EmployeeId = p.EmployeeId,
                    EmployeeName = p.Employee != null ? p.Employee.Name : "Unknown",
                    MonthYear = p.MonthYear,
                    PeriodStart = p.PeriodStart,
                    PeriodEnd = p.PeriodEnd,
                    BasicSalary = p.BasicSalary,
                    WorkedDays = p.WorkedDays,
                    OvertimeHours = p.OvertimeHours,
                    OvertimeRate = p.OvertimeRate,
                    Bonuses = p.Bonuses,
                    Advances = p.Advances,
                    OtherDeductions = p.OtherDeductions,
                    Epf8 = p.Epf8,
                    Tax = p.Tax,
                    Epf12 = p.Epf12,
                    Etf3 = p.Etf3,
                    NetSalary = p.NetSalary,
                    Status = p.Status.ToString(),
                    GeneratedDate = p.GeneratedDate
                })
                .ToListAsync();
        }
    }
}

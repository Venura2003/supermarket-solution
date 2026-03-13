using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;
using SupermarketAPI.DTOs;
using SupermarketAPI.Models;
using System.Security.Claims;

namespace SupermarketAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ExpensesController : ControllerBase
    {
        private readonly AppDbContext _context;

        public ExpensesController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/expenses
        [HttpGet]
        public async Task<ActionResult<IEnumerable<ExpenseDto>>> GetExpenses(
            [FromQuery] DateTime? startDate, 
            [FromQuery] DateTime? endDate, 
            [FromQuery] string? category)
        {
            var query = _context.Expenses.AsQueryable();

            if (startDate.HasValue)
                query = query.Where(e => e.Date >= startDate.Value);

            if (endDate.HasValue)
                query = query.Where(e => e.Date <= endDate.Value);

            if (!string.IsNullOrEmpty(category))
                query = query.Where(e => e.Category == category);

            var expenses = await query
                .OrderByDescending(e => e.Date)
                .Select(e => new ExpenseDto
                {
                    Id = e.Id,
                    Description = e.Description,
                    Category = e.Category,
                    Amount = e.Amount,
                    Date = e.Date,
                    CreatedBy = e.CreatedBy
                })
                .ToListAsync();

            return Ok(expenses);
        }

        // GET: api/expenses/5
        [HttpGet("{id}")]
        public async Task<ActionResult<ExpenseDto>> GetExpense(int id)
        {
            var expense = await _context.Expenses.FindAsync(id);

            if (expense == null)
            {
                return NotFound();
            }

            return Ok(new ExpenseDto
            {
                Id = expense.Id,
                Description = expense.Description,
                Category = expense.Category,
                Amount = expense.Amount,
                Date = expense.Date,
                CreatedBy = expense.CreatedBy
            });
        }

        // POST: api/expenses
        [HttpPost]
        public async Task<ActionResult<ExpenseDto>> CreateExpense(CreateExpenseDto expenseDto)
        {
            var user = HttpContext.User.FindFirst(ClaimTypes.Name)?.Value ?? "System"; // Get user from token if available

            var expense = new Expense
            {
                Description = expenseDto.Description,
                Category = expenseDto.Category,
                Amount = expenseDto.Amount,
                Date = expenseDto.Date == default ? DateTime.UtcNow : expenseDto.Date,
                CreatedBy = user
            };

            _context.Expenses.Add(expense);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetExpense), new { id = expense.Id }, new ExpenseDto
            {
                Id = expense.Id,
                Description = expense.Description,
                Category = expense.Category,
                Amount = expense.Amount,
                Date = expense.Date,
                CreatedBy = expense.CreatedBy
            });
        }

        // DELETE: api/expenses/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteExpense(int id)
        {
            var expense = await _context.Expenses.FindAsync(id);
            if (expense == null)
            {
                return NotFound();
            }

            _context.Expenses.Remove(expense);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        // GET: api/expenses/categories
        // Helper to get distinct categories
        [HttpGet("categories")]
        public async Task<ActionResult<IEnumerable<string>>> GetCategories()
        {
            var categories = await _context.Expenses
                .Select(e => e.Category)
                .Distinct()
                .ToListAsync();

            return Ok(categories);
        }
    }
}

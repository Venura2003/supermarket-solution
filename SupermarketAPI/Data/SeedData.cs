using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Models;

namespace SupermarketAPI.Data
{
    public static class SeedData
    {
        public static async Task SeedCategories(AppDbContext context)
        {
            if (context == null) return;

            // Ensure database is created (migrations should be applied by caller)
            // Check if any categories exist
            if (await context.Categories.AnyAsync())
                return;

            var defaultCategories = new[]
            {
                new Category { Name = "Beverages" },
                new Category { Name = "Groceries" },
                new Category { Name = "Dairy" },
                new Category { Name = "Snacks" },
                new Category { Name = "Household" }
            };

            await context.Categories.AddRangeAsync(defaultCategories);
            await context.SaveChangesAsync();
        }
    }
}

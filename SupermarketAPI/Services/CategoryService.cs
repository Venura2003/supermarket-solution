using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;
using SupermarketAPI.DTOs;
using SupermarketAPI.Models;

namespace SupermarketAPI.Services
{
    public class CategoryService : ICategoryService
    {
        private readonly AppDbContext _db;
        private readonly ILogger<CategoryService> _logger;

        public CategoryService(AppDbContext db, ILogger<CategoryService> logger)
        {
            _db = db;
            _logger = logger;
        }

        public async Task<IEnumerable<CategoryDto>> GetAllAsync()
        {
            var categories = await _db.Categories
                .AsNoTracking()
                .OrderBy(c => c.Name)
                .ToListAsync();

            return categories.Select(c => new CategoryDto(c.Id, c.Name));
        }

        public async Task<CategoryDto?> GetByIdAsync(int id)
        {
            var c = await _db.Categories
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.Id == id);

            if (c == null) return null;
            return new CategoryDto(c.Id, c.Name);
        }

        public async Task<CategoryDto> CreateAsync(CreateCategoryDto dto)
        {
            var name = dto.Name?.Trim() ?? string.Empty;

            // Prevent duplicate names (case-insensitive)
            var exists = await _db.Categories.AnyAsync(x => x.Name.ToLower() == name.ToLower());
            if (exists)
            {
                throw new InvalidOperationException("Category with the same name already exists.");
            }

            var category = new Category { Name = name };
            await _db.Categories.AddAsync(category);
            await _db.SaveChangesAsync();

            return new CategoryDto(category.Id, category.Name);
        }

        public async Task<bool> UpdateAsync(int id, UpdateCategoryDto dto)
        {
            var c = await _db.Categories.FirstOrDefaultAsync(x => x.Id == id);
            if (c == null) return false;

            var name = dto.Name?.Trim() ?? string.Empty;
            // Check for name conflict with other categories
            var conflict = await _db.Categories.AnyAsync(x => x.Id != id && x.Name.ToLower() == name.ToLower());
            if (conflict)
            {
                throw new InvalidOperationException("Another category with the same name exists.");
            }

            c.Name = name;
            _db.Categories.Update(c);
            await _db.SaveChangesAsync();
            return true;
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var c = await _db.Categories.FirstOrDefaultAsync(x => x.Id == id);
            if (c == null) return false;

            _db.Categories.Remove(c);
            await _db.SaveChangesAsync();
            return true;
        }
    }
}

using System.Linq;
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;
using SupermarketAPI.DTOs;
using SupermarketAPI.Models;

namespace SupermarketAPI.Services
{
    public class ProductService : IProductService
    {
        private readonly AppDbContext _context;
        private readonly ILogger<ProductService> _logger;

        public ProductService(AppDbContext context, ILogger<ProductService> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task<IEnumerable<ProductDto>> GetAllAsync()
        {
            return await _context.Products
                .AsNoTracking()
                .Select(p => new ProductDto(p.Id, p.Name, p.CategoryId, p.Barcode, p.ImageUrl, p.Price, p.Stock, p.LowStockThreshold, p.CreatedAt))
                .ToListAsync();
        }

        public async Task<ProductDto?> GetByIdAsync(int id)
        {
            var p = await _context.Products.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id);
            if (p == null) return null;
            return new ProductDto(p.Id, p.Name, p.CategoryId, p.Barcode, p.ImageUrl, p.Price, p.Stock, p.LowStockThreshold, p.CreatedAt);
        }

        public async Task<ProductDto?> GetByBarcodeAsync(string barcode)
        {
            if (string.IsNullOrWhiteSpace(barcode)) return null;
            var p = await _context.Products.AsNoTracking().FirstOrDefaultAsync(x => x.Barcode == barcode);
            if (p == null) return null;
            return new ProductDto(p.Id, p.Name, p.CategoryId, p.Barcode, p.ImageUrl, p.Price, p.Stock, p.LowStockThreshold, p.CreatedAt);
        }

        public async Task<ProductDto> CreateAsync(CreateProductDto dto)
        {
            var product = new Product
            {
                Name = dto.Name.Trim(),
                CategoryId = dto.CategoryId,
                Barcode = dto.Barcode,
                ImageUrl = dto.ImageUrl,
                Price = dto.Price,
                Stock = dto.Stock,
                LowStockThreshold = dto.LowStockThreshold,
                CreatedAt = DateTime.UtcNow
            };

            _context.Products.Add(product);
            await _context.SaveChangesAsync();

            _logger.LogInformation("Product created: {Id} {Name}", product.Id, product.Name);

            return new ProductDto(product.Id, product.Name, product.CategoryId, product.Barcode, product.ImageUrl, product.Price, product.Stock, product.LowStockThreshold, product.CreatedAt);
        }

        public async Task<bool> UpdateAsync(int id, UpdateProductDto dto)
        {
            var product = await _context.Products.FirstOrDefaultAsync(p => p.Id == id);
            if (product == null) return false;

            if (!string.IsNullOrWhiteSpace(dto.Name)) product.Name = dto.Name.Trim();
            if (dto.CategoryId.HasValue) product.CategoryId = dto.CategoryId;
            if (dto.Barcode != null) product.Barcode = dto.Barcode;
            if (dto.ImageUrl != null) product.ImageUrl = dto.ImageUrl;
            if (dto.Price.HasValue) product.Price = dto.Price.Value;
            if (dto.Stock.HasValue) product.Stock = dto.Stock.Value;
            if (dto.LowStockThreshold.HasValue) product.LowStockThreshold = dto.LowStockThreshold.Value;

            await _context.SaveChangesAsync();

            _logger.LogInformation("Product updated: {Id}", id);
            return true;
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var product = await _context.Products.FirstOrDefaultAsync(p => p.Id == id);
            if (product == null) return false;

            _context.Products.Remove(product);
            await _context.SaveChangesAsync();

            _logger.LogInformation("Product deleted: {Id}", id);
            return true;
        }
    }
}

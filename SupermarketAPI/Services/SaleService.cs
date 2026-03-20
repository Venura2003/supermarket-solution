using System;
using System.IO;
using System.Linq;
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Common;
using SupermarketAPI.Data;
using SupermarketAPI.DTOs;
using SupermarketAPI.Models;
using PdfSharpCore.Pdf;
using PdfSharpCore.Drawing;

namespace SupermarketAPI.Services
{
    public class SaleService : ISaleService
    {
        private readonly AppDbContext _context;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ILogger<SaleService> _logger;

        public SaleService(AppDbContext context, IUnitOfWork unitOfWork, ILogger<SaleService> logger)
        {
            _context = context;
            _unitOfWork = unitOfWork;
            _logger = logger;
        }

        public async Task<IEnumerable<SaleDto>> GetAllAsync()
        {
            var sales = await _context.Sales
                .Include(s => s.Employee)
                .Include(s => s.SaleItems)
                .ThenInclude(si => si.Product)
                .OrderByDescending(s => s.SaleDate)
                .ToListAsync();

            return sales.Select(MapToDto);
        }

        public async Task<SaleDto?> GetByIdAsync(int id)
        {
            var sale = await _context.Sales
                .Include(s => s.Employee)
                .Include(s => s.SaleItems)
                .ThenInclude(si => si.Product)
                .FirstOrDefaultAsync(s => s.Id == id);

            return sale == null ? null : MapToDto(sale);
        }

        public async Task<SaleDto> CreateAsync(CreateSaleDto dto, int employeeId)
        {
            var strategy = _context.Database.CreateExecutionStrategy();
            return await strategy.ExecuteAsync(async () =>
            {
                await _unitOfWork.BeginTransactionAsync();
                try
                {
                    // Generate unique sale number
                    var saleNo = GenerateSaleNo();

                    // Create sale
                    var sale = new Sale
                    {
                        SaleNo = saleNo,
                        EmployeeId = employeeId,
                        SaleDate = DateTime.UtcNow,
                        TotalAmount = dto.TotalAmount,
                        DiscountAmount = dto.DiscountAmount,
                        PaymentMethod = dto.PaymentMethod,
                        Status = "Completed",
                        Notes = dto.Notes,
                        SaleItems = new List<SaleItem>()
                    };

                    _context.Sales.Add(sale);
                    await _unitOfWork.SaveChangesAsync();

                    // Create sale items and update inventory
                    foreach (var itemDto in dto.Items)
                    {
                        var product = await _context.Products.FindAsync(itemDto.ProductId);
                        if (product == null)
                            throw new Exception($"Product {itemDto.ProductId} not found");

                        if (product.Stock < itemDto.Quantity)
                            throw new Exception($"Insufficient stock for product {product.Name}");

                        var saleItem = new SaleItem
                        {
                            SaleId = sale.Id,
                            ProductId = itemDto.ProductId,
                            Quantity = itemDto.Quantity,
                            UnitPrice = itemDto.UnitPrice,
                            Discount = itemDto.Discount,
                            LineTotal = itemDto.LineTotal
                        };

                        _context.SaleItems.Add(saleItem);

                        // Update product stock
                        product.Stock -= itemDto.Quantity;

                        // Log inventory change
                        var inventoryLog = new InventoryLog
                        {
                            ProductId = itemDto.ProductId,
                            Action = InventoryAction.StockOut.ToString(),
                            Quantity = itemDto.Quantity,
                            Reason = "Sale",
                            EmployeeId = employeeId,
                            Notes = $"Sale #{sale.SaleNo}"
                        };

                        _context.InventoryLogs.Add(inventoryLog);
                    }

                    await _unitOfWork.SaveChangesAsync();
                    await _unitOfWork.CommitTransactionAsync();

                    _logger.LogInformation("Sale {SaleNo} created successfully by employee {EmployeeId}", saleNo, employeeId);

                    // Check for low stock alerts
                    await CheckLowStockAlertsAsync();

                    // Pragmatic: avoid EF navigation that may fail on schema-mismatched Employee columns.
                    // Build a minimal SaleDto without including Employee navigation to prevent Invalid column exceptions.
                    var saleDto = new SaleDto
                    {
                        Id = sale.Id,
                        SaleNo = sale.SaleNo,
                        EmployeeId = sale.EmployeeId,
                        EmployeeName = null,
                        SaleDate = sale.SaleDate,
                        TotalAmount = sale.TotalAmount,
                        DiscountAmount = sale.DiscountAmount,
                        PaymentMethod = sale.PaymentMethod,
                        Status = sale.Status,
                        Notes = sale.Notes,
                        Items = new List<SaleItemDto>(),
                        CreatedAt = sale.CreatedAt
                    };

                    var items = await _context.SaleItems.Where(si => si.SaleId == sale.Id).ToListAsync();
                    foreach (var si in items)
                    {
                        var product = await _context.Products.FindAsync(si.ProductId);
                        saleDto.Items.Add(new SaleItemDto
                        {
                            Id = si.Id,
                            ProductId = si.ProductId,
                            ProductName = product?.Name,
                            Quantity = si.Quantity,
                            UnitPrice = si.UnitPrice,
                            Discount = si.Discount,
                            LineTotal = si.LineTotal
                        });
                    }

                    return saleDto;
                }
                catch (Exception ex)
                {
                    await _unitOfWork.RollbackTransactionAsync();
                    _logger.LogError(ex, "Failed to create sale for employee {EmployeeId}", employeeId);
                    throw;
                }
            });
        }

        public async Task<bool> UpdateStatusAsync(int id, string status)
        {
            var sale = await _context.Sales.FindAsync(id);
            if (sale == null) return false;

            sale.Status = status;
            sale.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<IEnumerable<SaleDto>> GetByEmployeeAsync(int employeeId)
        {
            var sales = await _context.Sales
                .Where(s => s.EmployeeId == employeeId)
                .Include(s => s.Employee)
                .Include(s => s.SaleItems)
                .ThenInclude(si => si.Product)
                .OrderByDescending(s => s.SaleDate)
                .ToListAsync();

            return sales.Select(MapToDto);
        }

        public async Task<IEnumerable<SaleDto>> GetByDateRangeAsync(DateTime startDate, DateTime endDate)
        {
            var sales = await _context.Sales
                .Where(s => s.SaleDate >= startDate && s.SaleDate <= endDate)
                .Include(s => s.Employee)
                .Include(s => s.SaleItems)
                .ThenInclude(si => si.Product)
                .OrderByDescending(s => s.SaleDate)
                .ToListAsync();

            return sales.Select(MapToDto);
        }

        public async Task<string> GenerateReceiptAsync(int saleId)
        {
            // Minimal PDF generation using PdfSharpCore. Requires PdfSharpCore package.
            var sale = await _context.Sales
                .Include(s => s.SaleItems)
                .ThenInclude(si => si.Product)
                // avoid including Employee navigation due to possible schema mismatches
                .FirstOrDefaultAsync(s => s.Id == saleId);

            if (sale == null) throw new Exception("Sale not found");

            var receiptsDir = Path.Combine(Directory.GetCurrentDirectory(), "Receipts");
            if (!Directory.Exists(receiptsDir)) Directory.CreateDirectory(receiptsDir);

            var fileName = $"receipt_{sale.SaleNo}.pdf";
            var fullPath = Path.Combine(receiptsDir, fileName);

            try
            {
                // Lazy create PDF using PdfSharpCore if available
                using (var document = new PdfSharpCore.Pdf.PdfDocument())
                {
                    var page = document.AddPage();
                    var gfx = PdfSharpCore.Drawing.XGraphics.FromPdfPage(page);
                    var font = new PdfSharpCore.Drawing.XFont("Verdana", 10);

                    var y = 20;
                    gfx.DrawString("FreshMart Lanka", new PdfSharpCore.Drawing.XFont("Verdana", 14, PdfSharpCore.Drawing.XFontStyle.Bold), PdfSharpCore.Drawing.XBrushes.Black, new PdfSharpCore.Drawing.XPoint(20, y));
                    y += 30;
                    gfx.DrawString($"Sale: {sale.SaleNo}", font, PdfSharpCore.Drawing.XBrushes.Black, new PdfSharpCore.Drawing.XPoint(20, y));
                    y += 20;
                    gfx.DrawString($"Date: {sale.SaleDate:u}", font, PdfSharpCore.Drawing.XBrushes.Black, new PdfSharpCore.Drawing.XPoint(20, y));
                    y += 20;

                    gfx.DrawString("Items:", font, PdfSharpCore.Drawing.XBrushes.Black, new PdfSharpCore.Drawing.XPoint(20, y));
                    y += 18;
                    foreach (var si in sale.SaleItems)
                    {
                        var line = $"{si.Product?.Name} x{si.Quantity} @ {si.UnitPrice:F2} = {si.LineTotal:F2}";
                        gfx.DrawString(line, font, PdfSharpCore.Drawing.XBrushes.Black, new PdfSharpCore.Drawing.XPoint(20, y));
                        y += 16;
                    }

                    y += 8;
                    gfx.DrawString($"Total: {sale.TotalAmount:F2}", font, PdfSharpCore.Drawing.XBrushes.Black, new PdfSharpCore.Drawing.XPoint(20, y));
                    y += 16;
                    gfx.DrawString($"Payment: {sale.PaymentMethod}", font, PdfSharpCore.Drawing.XBrushes.Black, new PdfSharpCore.Drawing.XPoint(20, y));

                    using (var stream = File.OpenWrite(fullPath))
                    {
                        document.Save(stream);
                    }
                }

                // Return a web-accessible URL path (relative to the API base).
                // Frontend will call GET {apiBaseUrl}/sales/receipts/{fileName} to download.
                return $"/sales/receipts/{fileName}";
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to generate receipt for sale {SaleId}", saleId);
                throw;
            }
        }

        private string GenerateSaleNo()
        {
            return $"SAL-{DateTime.UtcNow:yyyyMMdd}-{Guid.NewGuid().ToString().Substring(0, 8).ToUpper()}";
        }

        private async Task CheckLowStockAlertsAsync()
        {
            var lowStockProducts = await _context.Products
                .Where(p => p.Stock <= p.LowStockThreshold)
                .ToListAsync();

            foreach (var product in lowStockProducts)
            {
                var existingAlert = await _context.Notifications
                    .FirstOrDefaultAsync(n => n.Title.Contains($"Low Stock: {product.Name}") && !n.IsRead);

                if (existingAlert == null)
                {
                    var notification = new Notification
                    {
                        Title = $"Low Stock Alert: {product.Name}",
                        Message = $"Product '{product.Name}' has low stock ({product.Stock} remaining). Threshold: {product.LowStockThreshold}",
                        Type = "Warning"
                    };

                    _context.Notifications.Add(notification);
                }
            }

            await _context.SaveChangesAsync();
        }

        private static SaleDto MapToDto(Sale sale)
        {
            return new SaleDto
            {
                Id = sale.Id,
                SaleNo = sale.SaleNo,
                EmployeeId = sale.EmployeeId,
                EmployeeName = sale.Employee?.Name,
                SaleDate = sale.SaleDate,
                TotalAmount = sale.TotalAmount,
                DiscountAmount = sale.DiscountAmount,
                PaymentMethod = sale.PaymentMethod,
                Status = sale.Status,
                Notes = sale.Notes,
                Items = sale.SaleItems.Select(si => new SaleItemDto
                {
                    Id = si.Id,
                    ProductId = si.ProductId,
                    ProductName = si.Product?.Name,
                    Quantity = si.Quantity,
                    UnitPrice = si.UnitPrice,
                    Discount = si.Discount,
                    LineTotal = si.LineTotal
                }).ToList(),
                CreatedAt = sale.CreatedAt
            };
        }
    }
}
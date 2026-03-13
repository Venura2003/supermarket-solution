using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Common;
using SupermarketAPI.Common.Exceptions;
using SupermarketAPI.Data;
using SupermarketAPI.DTOs;
using SupermarketAPI.Models;
using PdfSharpCore.Pdf;
using PdfSharpCore.Drawing;

namespace SupermarketAPI.Services
{
    public class OrderService : IOrderService
    {
        private readonly AppDbContext _db;
        private readonly ILogger<OrderService> _logger;

        public OrderService(AppDbContext db, ILogger<OrderService> logger)
        {
            _db = db;
            _logger = logger;
        }

        public async Task<OrderDto> CreateOrderAsync(CreateOrderDto dto, int employeeId)
        {
            using var transaction = await _db.Database.BeginTransactionAsync();
            try
            {
                // Validate items exist and have stock
                var productIds = dto.Items.Select(i => i.ProductId).Distinct().ToList();
                var products = await _db.Products
                    .Where(p => productIds.Contains(p.Id))
                    .ToDictionaryAsync(p => p.Id);

                if (products.Count != productIds.Count)
                {
                    throw new InvalidProductException("One or more products not found");
                }

                decimal orderTotal = 0;
                var orderItems = new List<OrderItem>();

                // Create order items and validate stock
                foreach (var item in dto.Items)
                {
                    var product = products[item.ProductId];

                    if (product.Stock < item.Quantity)
                    {
                        throw new InsufficientStockException(
                            item.ProductId,
                            item.Quantity,
                            product.Stock
                        );
                    }

                    var unitPrice = item.CustomDiscount.HasValue 
                        ? product.Price * (1 - (item.CustomDiscount.Value / 100)) 
                        : product.Price;

                    var lineTotal = unitPrice * item.Quantity;

                    var orderItem = new OrderItem
                    {
                        ProductId = item.ProductId,
                        Quantity = item.Quantity,
                        UnitPrice = unitPrice,
                        Discount = item.CustomDiscount ?? 0,
                        LineTotal = lineTotal
                    };

                    orderItems.Add(orderItem);
                    orderTotal += lineTotal;
                }

                // Calculate Totals with VAT (12%)
                // User requirement: Price should include VAT and Discount.
                // Assuming the 'orderTotal' is the Net Amount before tax for now.
                // Or if unitPrice includes tax, then just add it.
                // Let's assume standard behavior: SubTotal + Tax - Discount = Total
                
                decimal subTotal = orderTotal;
                decimal taxRate = 0.12m; // 12% VAT
                decimal taxAmount = subTotal * taxRate;
                decimal discountAmount = dto.Discount; // Expected as Amount from Frontend (converted from %)

                decimal finalTotal = subTotal + taxAmount - discountAmount;
                if (finalTotal < 0) finalTotal = 0;

                // Create order
                var order = new Order
                {
                    OrderNo = GenerateOrderNo(),
                    EmployeeId = employeeId,
                    OrderDate = DateTime.UtcNow,
                    PaymentMethod = dto.PaymentMethod,
                    Status = OrderStatus.Completed.ToString(),
                    DiscountAmount = discountAmount,
                    TotalAmount = finalTotal,
                    Notes = dto.Notes,
                    OrderItems = orderItems
                };

                // Deduct stock from products and log inventory
                foreach (var item in dto.Items)
                {
                    var product = products[item.ProductId];
                    product.Stock -= item.Quantity;

                    var inventoryLog = new InventoryLog
                    {
                        ProductId = item.ProductId,
                        Action = InventoryAction.StockOut.ToString(),
                        Quantity = item.Quantity,
                        Reason = "Sale",
                        EmployeeId = employeeId,
                        Notes = $"Order #{order.OrderNo}"
                    };
                    _db.InventoryLogs.Add(inventoryLog);
                }

                await _db.Orders.AddAsync(order);
                await _db.SaveChangesAsync();
                await transaction.CommitAsync();

                _logger.LogInformation(
                    $"Order {order.OrderNo} created. Items: {order.OrderItems.Count}, Total: {order.TotalAmount}, Employee: {employeeId}"
                );
                
                // Check for low stock alerts
                await CheckLowStockAlertsAsync();

                return (await GetOrderByIdAsync(order.Id))!;
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                _logger.LogError(ex, "Error creating order");
                throw;
            }
        }

        public async Task<OrderDto?> GetOrderByIdAsync(int id)
        {
            var order = await _db.Orders
                .Include(o => o.OrderItems)
                .ThenInclude(oi => oi.Product)
                .Include(o => o.Employee)
                .ThenInclude(e => e.User)
                .FirstOrDefaultAsync(o => o.Id == id);

            if (order == null)
                return null;

            return MapToDto(order);
        }

        public async Task<IEnumerable<OrderDto>> GetOrdersAsync(OrderFilterDto filter)
        {
            var query = _db.Orders
                .Include(o => o.OrderItems)
                .ThenInclude(oi => oi.Product)
                .Include(o => o.Employee)
                .AsQueryable();

            if (filter.StartDate.HasValue)
                query = query.Where(o => o.OrderDate >= filter.StartDate);

            if (filter.EndDate.HasValue)
                query = query.Where(o => o.OrderDate <= filter.EndDate);

            if (!string.IsNullOrEmpty(filter.PaymentMethod))
                query = query.Where(o => o.PaymentMethod == filter.PaymentMethod);

            if (!string.IsNullOrEmpty(filter.Status))
                query = query.Where(o => o.Status == filter.Status);

            var orders = await query
                .OrderByDescending(o => o.OrderDate)
                .Skip((filter.PageNumber - 1) * filter.PageSize)
                .Take(filter.PageSize)
                .ToListAsync();

            return orders.Select(MapToDto);
        }

        public async Task<bool> CancelOrderAsync(int id)
        {
            using var transaction = await _db.Database.BeginTransactionAsync();
            try
            {
                var order = await _db.Orders
                    .Include(o => o.OrderItems)
                    .FirstOrDefaultAsync(o => o.Id == id);

                if (order == null) return false;

                if (order.Status == OrderStatus.Cancelled.ToString())
                    return false;

                // Restore stock
                foreach (var item in order.OrderItems)
                {
                    var product = await _db.Products.FirstOrDefaultAsync(p => p.Id == item.ProductId);
                    if (product != null)
                    {
                        product.Stock += item.Quantity;
                    }
                }

                order.Status = OrderStatus.Cancelled.ToString();
                order.UpdatedAt = DateTime.UtcNow;

                await _db.SaveChangesAsync();
                await transaction.CommitAsync();

                _logger.LogInformation($"Order {order.OrderNo} cancelled");
                return true;
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                _logger.LogError(ex, "Error cancelling order");
                throw;
            }
        }

        public async Task<bool> RefundOrderAsync(int id)
        {
            using var transaction = await _db.Database.BeginTransactionAsync();
            try
            {
                var order = await _db.Orders
                    .Include(o => o.OrderItems)
                    .FirstOrDefaultAsync(o => o.Id == id);

                if (order == null) return false;

                if (order.Status != OrderStatus.Completed.ToString())
                    throw new InvalidOperationException("Only completed orders can be refunded.");

                // Restore stock
                foreach (var item in order.OrderItems)
                {
                    var product = await _db.Products.FirstOrDefaultAsync(p => p.Id == item.ProductId);
                    if (product != null)
                    {
                        product.Stock += item.Quantity;
                    }
                }

                order.Status = OrderStatus.Refunded.ToString();
                order.UpdatedAt = DateTime.UtcNow;

                await _db.SaveChangesAsync();
                await transaction.CommitAsync();

                _logger.LogInformation($"Order {order.OrderNo} refunded");
                return true;
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                _logger.LogError(ex, "Error refunding order");
                throw;
            }
        }
        public async Task<bool> RefundOrderItemsAsync(int orderId, RefundRequestDto request)
        {
            using var transaction = await _db.Database.BeginTransactionAsync();
            try
            {
                var order = await _db.Orders
                    .Include(o => o.OrderItems)
                    .FirstOrDefaultAsync(o => o.Id == orderId);

                if (order == null) return false;

                if (order.Status == OrderStatus.Refunded.ToString())
                     throw new InvalidOperationException("Order is already fully refunded.");

                bool allRefunded = true;

                foreach (var refItem in request.Items)
                {
                    var orderItem = order.OrderItems.FirstOrDefault(oi => oi.Id == refItem.OrderItemId);
                    if (orderItem == null) continue; // Skip if not found, or throw?

                    if (refItem.Quantity <= 0) continue;
                    
                    if (orderItem.RefundedQuantity + refItem.Quantity > orderItem.Quantity)
                    {
                        throw new InvalidOperationException($"Cannot refund {refItem.Quantity} for item {orderItem.ProductId}. Max refundable: {orderItem.Quantity - orderItem.RefundedQuantity}");
                    }

                    // Update Refunded Qty
                    orderItem.RefundedQuantity += refItem.Quantity;

                    // Restore Stock
                    var product = await _db.Products.FirstOrDefaultAsync(p => p.Id == orderItem.ProductId);
                    if (product != null)
                    {
                        product.Stock += refItem.Quantity;
                    }
                }

                // Check if totally refunded
                foreach(var item in order.OrderItems)
                {
                    if (item.RefundedQuantity < item.Quantity)
                    {
                        allRefunded = false;
                        break;
                    } 
                }

                if (allRefunded)
                {
                    order.Status = OrderStatus.Refunded.ToString();
                }

                order.UpdatedAt = DateTime.UtcNow;
                await _db.SaveChangesAsync();
                await transaction.CommitAsync();
                
                return true;
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                _logger.LogError(ex, "Error partial refunding order");
                throw;
            }
        }
        public async Task<decimal> GetTotalSalesAsync(DateTime from, DateTime to)
        {
            return await _db.Orders
                .Where(o => o.OrderDate >= from && o.OrderDate <= to 
                    && o.Status == OrderStatus.Completed.ToString())
                .SumAsync(o => o.TotalAmount);
        }

        public async Task<int> GetTotalOrdersAsync(DateTime from, DateTime to)
        {
            return await _db.Orders
                .Where(o => o.OrderDate >= from && o.OrderDate <= to
                    && o.Status == OrderStatus.Completed.ToString())
                .CountAsync();
        }

        public async Task<string> GenerateReceiptAsync(int orderId)
        {
            var order = await _db.Orders
                .Include(o => o.OrderItems)
                .ThenInclude(oi => oi.Product)
                .Include(o => o.Employee)
                .FirstOrDefaultAsync(o => o.Id == orderId);

            if (order == null) throw new Exception("Order not found");

            var receiptsDir = Path.Combine(Directory.GetCurrentDirectory(), "Receipts");
            if (!Directory.Exists(receiptsDir)) Directory.CreateDirectory(receiptsDir);

            var fileName = $"receipt_{order.OrderNo}.pdf";
            var fullPath = Path.Combine(receiptsDir, fileName);

            try
            {
                // Create a PDF document for thermal printer (approx 80mm width)
                using (var document = new PdfSharpCore.Pdf.PdfDocument())
                {
                    var page = document.AddPage();
                    // 80mm is approx 226 points.
                    page.Width = PdfSharpCore.Drawing.XUnit.FromMillimeter(80);
                    
                    // Estimate Height dynamically
                    double estimatedHeight = 220 + (order.OrderItems.Count * 25) + 100;
                    page.Height = PdfSharpCore.Drawing.XUnit.FromPoint(estimatedHeight);

                    var gfx = PdfSharpCore.Drawing.XGraphics.FromPdfPage(page);
                    
                    var fontRegular = new PdfSharpCore.Drawing.XFont("Courier New", 8);
                    var fontBold = new PdfSharpCore.Drawing.XFont("Courier New", 8, PdfSharpCore.Drawing.XFontStyle.Bold);
                    var fontHeader = new PdfSharpCore.Drawing.XFont("Courier New", 12, PdfSharpCore.Drawing.XFontStyle.Bold);
                    var fontSmall = new PdfSharpCore.Drawing.XFont("Courier New", 7);

                    double y = 10;
                    double pageWidth = page.Width.Point;
                    double margin = 5; // Small margin for thermal paper

                    void DrawCenter(string text, PdfSharpCore.Drawing.XFont f, double yPos)
                    {
                        var size = gfx.MeasureString(text, f);
                        gfx.DrawString(text, f, PdfSharpCore.Drawing.XBrushes.Black, new PdfSharpCore.Drawing.XPoint((pageWidth - size.Width) / 2, yPos));
                    }

                    void DrawLeftRight(string left, string right, PdfSharpCore.Drawing.XFont f, double yPos)
                    {
                        var sizeRight = gfx.MeasureString(right, f);
                        gfx.DrawString(left, f, PdfSharpCore.Drawing.XBrushes.Black, new PdfSharpCore.Drawing.XPoint(margin, yPos));
                        gfx.DrawString(right, f, PdfSharpCore.Drawing.XBrushes.Black, new PdfSharpCore.Drawing.XPoint(pageWidth - margin - sizeRight.Width, yPos));
                    }

                    void DrawLine(double yPos)
                    {
                         gfx.DrawLine(new PdfSharpCore.Drawing.XPen(PdfSharpCore.Drawing.XColors.Black, 0.5) { DashStyle = PdfSharpCore.Drawing.XDashStyle.Dash }, margin, yPos, pageWidth - margin, yPos);
                    }

                    // --- Header ---
                    var headerText = (order.Employee?.User?.Username?.ToLower() == "bar") ? "TOP BAR" : "FRESHMART LANKA";
                    DrawCenter(headerText, fontHeader, y); y += 15;
                    DrawCenter("123, Grocery Street,", fontSmall, y); y += 10;
                    DrawCenter("Colombo 07, Sri Lanka", fontSmall, y); y += 10;
                    DrawCenter("Tel: +94 11 234 5678", fontSmall, y); y += 15;
                    
                    DrawLine(y); y += 10;

                    // --- Order Details ---
                    DrawLeftRight($"Order: #{order.OrderNo}", "", fontBold, y); y += 12;
                    var orderTime = order.OrderDate.ToUniversalTime().AddHours(5).AddMinutes(30);
                    DrawLeftRight($"Date: {orderTime:yyyy-MM-dd}", $"{orderTime:HH:mm}", fontRegular, y); y += 12;
                    DrawLeftRight($"Cashier: {order.Employee?.Name ?? "Admin"}", "", fontRegular, y); y += 15;

                    DrawLine(y); y += 10;

                    // --- Items Header ---
                    DrawLeftRight("Item", "Total", fontBold, y); y += 12;
                    
                    // --- Items ---
                    decimal calculatedSubTotal = 0;
                    foreach(var item in order.OrderItems)
                    {
                        calculatedSubTotal += item.LineTotal;
                        string name = item.Product?.Name ?? "Item";
                        if (name.Length > 18) name = name.Substring(0, 18) + "..";
                        
                        // Line 1: Name and Total
                        var totalStr = item.LineTotal.ToString("F2");
                        var sizeTotal = gfx.MeasureString(totalStr, fontRegular);
                        
                        gfx.DrawString(name, fontRegular, PdfSharpCore.Drawing.XBrushes.Black, new PdfSharpCore.Drawing.XPoint(margin, y));
                        gfx.DrawString(totalStr, fontRegular, PdfSharpCore.Drawing.XBrushes.Black, new PdfSharpCore.Drawing.XPoint(pageWidth - margin - sizeTotal.Width, y));
                        y += 10;

                        // Line 2: Qty x UnitPrice
                        string qtyPrice = $"  {item.Quantity} x {item.UnitPrice:F2}";
                        gfx.DrawString(qtyPrice, fontSmall, PdfSharpCore.Drawing.XBrushes.Gray, new PdfSharpCore.Drawing.XPoint(margin, y));
                        y += 12;
                    }

                    y += 5;
                    DrawLine(y); y += 10;

                    decimal calculatedTax = calculatedSubTotal * 0.12m;

                    // --- Totals ---
                    DrawLeftRight("Subtotal", calculatedSubTotal.ToString("F2"), fontRegular, y); y += 12;
                    
                    if (order.DiscountAmount > 0)
                    {
                         DrawLeftRight("Discount", $"-{order.DiscountAmount:F2}", fontRegular, y); y += 12;
                    }
                    
                    DrawLeftRight("VAT (12%)", calculatedTax.ToString("F2"), fontSmall, y); y += 15;

                    // --- Grand Total ---
                    DrawLeftRight("TOTAL", order.TotalAmount.ToString("F2"), fontHeader, y); y += 20;

                    DrawLeftRight("Details:", order.PaymentMethod ?? "Cash", fontRegular, y); y += 20;

                    // --- Footer ---
                    DrawCenter("*** THANK YOU! ***", fontBold, y); y += 12;
                    DrawCenter("Come Again", fontRegular, y); y += 12;
                    DrawCenter("Use our App for Delivery", fontSmall, y); y += 12;
                    
                    // Save document
                    document.Save(fullPath);
                }

                return $"/sales/receipts/{fileName}";
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to generate receipt for order {OrderId}", orderId);
                throw;
            }
        }

        private async Task CheckLowStockAlertsAsync()
        {
            var lowStockProducts = await _db.Products
                .Where(p => p.Stock <= p.LowStockThreshold)
                .ToListAsync();

            foreach (var product in lowStockProducts)
            {
                var existingAlert = await _db.Notifications
                    .FirstOrDefaultAsync(n => n.Title.Contains($"Low Stock: {product.Name}") && !n.IsRead);

                if (existingAlert == null)
                {
                    var notification = new Notification
                    {
                        Title = $"Low Stock Alert: {product.Name}",
                        Message = $"Product '{product.Name}' has low stock ({product.Stock} remaining). Threshold: {product.LowStockThreshold}",
                        Type = "Warning"
                    };

                    _db.Notifications.Add(notification);
                }
            }

            await _db.SaveChangesAsync();
        }

        private OrderDto MapToDto(Order order)
        {
            return new OrderDto(
                order.Id,
                order.OrderNo,
                order.EmployeeId,
                order.Employee?.Name ?? "Unknown",
                order.OrderDate,
                order.TotalAmount,
                order.DiscountAmount,
                order.PaymentMethod,
                order.Status,
                order.OrderItems.Select(oi => new OrderItemDto(
                    oi.Id,
                    oi.ProductId,
                    oi.Product?.Name ?? "Unknown",
                    oi.Quantity,
                    oi.UnitPrice,
                    oi.Discount,
                    oi.LineTotal
                )).ToList()
            );
        }

        private static string GenerateOrderNo()
        {
            return $"ORD-{DateTime.UtcNow:yyyyMMddHHmmss}-{new Random().Next(1000, 9999)}";
        }
    }
}

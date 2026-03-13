# FreshMart Lanka - Production-Ready POS System
## Implementation Plan & Architecture Guide

**Project Overview:**
FreshMart Lanka is a real-world supermarket POS (Point of Sale) system built with ASP.NET Core 8 API + Flutter Windows Desktop. This document outlines a realistic, phased implementation plan for a production-grade system.

---

## PROJECT ARCHITECTURE

### Backend Stack
- **Framework:** ASP.NET Core 8 (C#)
- **Database:** SQL Server (LocalDB or Enterprise)
- **ORM:** Entity Framework Core
- **Auth:** JWT + Role-Based Access Control (RBAC)
- **Logging:** Structured logging (Serilog recommended)
- **Validation:** FluentValidation
- **API:** RESTful with OpenAPI/Swagger

### Frontend Stack
- **Framework:** Flutter (Windows Desktop)
- **State Management:** Provider
- **HTTP Client:** http package
- **Local Storage:** shared_preferences
- **UI Framework:** Material 3

### Database Design Pattern
- Clean separation: Users, Products, Categories, Orders (Sales), OrderItems, Employees, Attendance
- Foreign key constraints with cascade/restrict behavior
- Indexes on frequently queried columns (Barcode, Email, Date ranges)
- Transaction support for Order processing

---

## PHASE 1: CORE POS & CLEAN ARCHITECTURE (Weeks 1-3)
**Goal:** Foundation for a functional POS system with proper architecture.

### 1.1 Database Schema Enhancements
**New Models:**
- `Employee` (Id, Name, Email, Phone, Role, Salary, HireDate, IsActive)
- `Order` (Id, OrderNo, EmployeeId, OrderDate, TotalAmount, PaymentMethod, Status)
- `OrderItem` (Id, OrderId, ProductId, Quantity, UnitPrice, Discount, LineTotal)
- `Attendance` (Id, EmployeeId, Date, CheckIn, CheckOut, Status)

**Enhancements:**
- Add `Barcode` unique index on `Product`
- Add `ImageUrl` nullable field on `Product`
- Add `LowStockThreshold` on `Product` (already exists)
- Add `Email` unique index on `User`
- Add `IsActive` flag on `User` and `Employee`

**Implementation:**
```
EF Core Migration: AddSalesAndEmployeeModels
- Create tables with proper relationships
- Add indexes and constraints
- Set up foreign keys (Products → Categories, Orders → Employees/Products)
```

### 1.2 Clean Architecture - Folder Structure
```
SupermarketAPI/
├── Controllers/
│   ├── AuthController.cs
│   ├── ProductsController.cs
│   ├── CategoriesController.cs
│   ├── OrdersController.cs          [NEW]
│   ├── EmployeesController.cs       [NEW]
│   ├── AttendanceController.cs      [NEW]
│   └── ReportsController.cs         [NEW]
│
├── Services/
│   ├── IAuthService.cs
│   ├── AuthService.cs
│   ├── IProductService.cs
│   ├── ProductService.cs
│   ├── ICategoryService.cs
│   ├── CategoryService.cs
│   ├── IOrderService.cs             [NEW]
│   ├── OrderService.cs              [NEW]
│   ├── IEmployeeService.cs          [NEW]
│   ├── EmployeeService.cs           [NEW]
│   ├── IAttendanceService.cs        [NEW]
│   └── AttendanceService.cs         [NEW]
│
├── Repositories/ (Optional, recommended)
│   ├── IRepository.cs               [NEW - Generic base pattern]
│   ├── OrderRepository.cs
│   ├── EmployeeRepository.cs
│   └── IUnitOfWork.cs               [NEW - Transaction handling]
│
├── DTOs/
│   ├── Order/
│   │   ├── CreateOrderDto.cs        [NEW]
│   │   ├── OrderDto.cs              [NEW]
│   │   ├── OrderItemDto.cs          [NEW]
│   │   └── OrderFilterDto.cs        [NEW]
│   ├── Employee/
│   │   ├── CreateEmployeeDto.cs     [NEW]
│   │   ├── EmployeeDto.cs           [NEW]
│   │   └── UpdateEmployeeDto.cs     [NEW]
│   └── Report/
│       ├── SalesReportDto.cs        [NEW]
│       └── StockReportDto.cs        [NEW]
│
├── Models/
│   ├── Order.cs                     [NEW]
│   ├── OrderItem.cs                 [NEW]
│   ├── Employee.cs                  [NEW]
│   ├── Attendance.cs                [NEW]
│   ├── Product.cs                   [ENHANCED]
│   ├── Category.cs
│   └── User.cs
│
├── Data/
│   ├── AppDbContext.cs              [UPDATED]
│   ├── SeedData.cs                  [UPDATED]
│   └── Migrations/
│
├── Middleware/
│   ├── ExceptionMiddleware.cs       [EXISTING]
│   └── LoggingMiddleware.cs         [NEW - Request/response logging]
│
├── Common/
│   ├── Constants.cs                 [NEW - Role names, statuses]
│   ├── Enums.cs                     [NEW - OrderStatus, PaymentMethod, etc]
│   ├── Exceptions.cs                [NEW - Custom exception classes]
│   └── Extensions.cs                [NEW - Helper extensions]
│
├── Configuration/
│   ├── JwtSettings.cs               [NEW - Config class]
│   ├── AppSettings.cs               [NEW - App settings binding]
│   └── ServiceExtensions.cs         [NEW - DI registration helpers]
│
└── Program.cs                        [UPDATED]
```

### 1.3 Key Enums & Constants
**OrderStatus:**
```csharp
public enum OrderStatus
{
    Pending,      // Order created, awaiting payment
    Completed,    // Payment received, order finalized
    Cancelled,    // Order cancelled
    Refunded      // Order refunded
}

public enum PaymentMethod
{
    Cash,
    Card,
    Cheque,
    OnlineTransfer
}

public enum AttendanceStatus
{
    Present,
    Absent,
    Late,
    LeaveApproved,
    OnDuty
}

public enum UserRole
{
    Admin,        // Full system access
    Manager,      // Reports & employee management
    Cashier,      // POS & order creation
    Warehouse     // Stock & inventory
}
```

### 1.4 Core DTOs & Validation
**OrderService DTOs:**
```csharp
public record CreateOrderDto(
    List<OrderItemRequestDto> Items,     // Product ID + Quantity
    decimal Discount = 0,
    string PaymentMethod,
    string Notes = ""
);

public record OrderItemRequestDto(
    int ProductId,
    int Quantity,
    decimal? CustomPrice = null          // Allow cashier override (with admin approval)
);

public record OrderDto(
    int Id,
    string OrderNo,
    int EmployeeId,
    DateTime OrderDate,
    decimal TotalAmount,
    decimal DiscountAmount,
    string PaymentMethod,
    string Status,
    List<OrderItemDto> Items
);

public record OrderItemDto(
    int Id,
    int ProductId,
    string ProductName,
    int Quantity,
    decimal UnitPrice,
    decimal LineTotal
);
```

**Validation (FluentValidation):**
```csharp
public class CreateOrderDtoValidator : AbstractValidator<CreateOrderDto>
{
    public CreateOrderDtoValidator()
    {
        RuleFor(x => x.Items)
            .NotEmpty().WithMessage("Order must contain at least one item");
        
        RuleFor(x => x.PaymentMethod)
            .Must(x => new[] { "Cash", "Card", "Cheque", "OnlineTransfer" }.Contains(x))
            .WithMessage("Invalid payment method");
    }
}
```

### 1.5 Core Service Implementations

### IOrderService Interface
```csharp
public interface IOrderService
{
    Task<OrderDto> CreateOrderAsync(CreateOrderDto dto, int employeeId);
    Task<OrderDto> GetOrderByIdAsync(int id);
    Task<IEnumerable<OrderDto>> GetOrdersAsync(OrderFilterDto filter);
    Task<bool> CancelOrderAsync(int id);
    Task<decimal> GetTotalSalesAsync(DateTime from, DateTime to);
    Task<int> GetTotalOrdersAsync(DateTime from, DateTime to);
}
```

**OrderService Implementation (with transaction handling):**
```csharp
public class OrderService : IOrderService
{
    private readonly AppDbContext _db;
    private readonly IProductService _productService;
    private readonly ILogger<OrderService> _logger;

    public async Task<OrderDto> CreateOrderAsync(CreateOrderDto dto, int employeeId)
    {
        using var transaction = await _db.Database.BeginTransactionAsync();
        try
        {
            var order = new Order
            {
                OrderNo = GenerateOrderNo(),
                EmployeeId = employeeId,
                OrderDate = DateTime.UtcNow,
                PaymentMethod = dto.PaymentMethod,
                Status = OrderStatus.Completed.ToString(),
                DiscountAmount = dto.Discount
            };

            decimal orderTotal = 0;

            foreach (var item in dto.Items)
            {
                var product = await _db.Products
                    .FirstOrDefaultAsync(p => p.Id == item.ProductId);
                
                if (product == null)
                    throw new InvalidOperationException($"Product {item.ProductId} not found");
                
                if (product.Stock < item.Quantity)
                    throw new InvalidOperationException($"Insufficient stock for {product.Name}");

                var lineTotal = (product.Price * item.Quantity) * (1 - (item.CustomPrice ?? 0));
                
                var orderItem = new OrderItem
                {
                    ProductId = item.ProductId,
                    Quantity = item.Quantity,
                    UnitPrice = product.Price,
                    LineTotal = lineTotal
                };

                order.OrderItems.Add(orderItem);
                product.Stock -= item.Quantity;          // Deduct stock
                orderTotal += lineTotal;
            }

            order.TotalAmount = orderTotal - dto.Discount;

            await _db.Orders.AddAsync(order);
            await _db.SaveChangesAsync();
            await transaction.CommitAsync();

            _logger.LogInformation($"Order {order.OrderNo} created with total {order.TotalAmount}");
            return MapToDto(order);
        }
        catch
        {
            await transaction.RollbackAsync();
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

    // ... other methods
}
```

### 1.6 Controllers with Proper Validation & Error Handling

**OrdersController:**
```csharp
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class OrdersController : ControllerBase
{
    private readonly IOrderService _service;
    private readonly IValidator<CreateOrderDto> _validator;

    [HttpPost]
    [Authorize(Roles = "Cashier,Admin")]
    public async Task<IActionResult> CreateOrder([FromBody] CreateOrderDto dto)
    {
        var validation = await _validator.ValidateAsync(dto);
        if (!validation.IsValid)
            return BadRequest(new { errors = validation.Errors });

        try
        {
            var orderId = User.FindFirst(ClaimTypes.NameIdentifier);
            var order = await _service.CreateOrderAsync(dto, int.Parse(orderId.Value));
            return CreatedAtAction(nameof(GetOrder), new { id = order.Id }, order);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetOrder(int id)
    {
        var order = await _service.GetOrderByIdAsync(id);
        if (order == null) return NotFound();
        return Ok(order);
    }

    [HttpGet]
    public async Task<IActionResult> GetOrders([FromQuery] OrderFilterDto filter)
    {
        var orders = await _service.GetOrdersAsync(filter);
        return Ok(orders);
    }
}
```

### 1.7 Database Context Updates
```csharp
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    // Product Configuration
    modelBuilder.Entity<Product>(entity =>
    {
        entity.Property(p => p.Price).HasPrecision(18, 2);
        entity.Property(p => p.Name).IsRequired().HasMaxLength(255);
        entity.Property(p => p.Barcode).HasMaxLength(128);
        entity.HasIndex(p => p.Barcode).IsUnique();
        entity.HasOne(p => p.Category).WithMany().OnDelete(DeleteBehavior.SetNull);
    });

    // NEW: Order Configuration (Transaction safety)
    modelBuilder.Entity<Order>(entity =>
    {
        entity.Property(o => o.OrderNo).IsRequired().HasMaxLength(50);
        entity.HasIndex(o => o.OrderNo).IsUnique();
        entity.Property(o => o.TotalAmount).HasPrecision(18, 2);
        entity.Property(o => o.DiscountAmount).HasPrecision(18, 2);
        entity.HasOne(o => o.Employee).WithMany(e => e.Orders).OnDelete(DeleteBehavior.Restrict);
    });

    // NEW: OrderItem Configuration
    modelBuilder.Entity<OrderItem>(entity =>
    {
        entity.Property(oi => oi.UnitPrice).HasPrecision(18, 2);
        entity.Property(oi => oi.LineTotal).HasPrecision(18, 2);
        entity.HasOne(oi => oi.Product).WithMany().OnDelete(DeleteBehavior.Restrict);
    });

    // NEW: Employee Configuration
    modelBuilder.Entity<Employee>(entity =>
    {
        entity.Property(e => e.Email).IsRequired().HasMaxLength(255);
        entity.HasIndex(e => e.Email).IsUnique();
        entity.Property(e => e.Salary).HasPrecision(18, 2);
    });
}
```

### 1.8 Exceptions & Error Handling

**Custom Exceptions:**
```csharp
public class InvalidProductException : Exception
{
    public InvalidProductException(string message) : base(message) { }
}

public class InsufficientStockException : Exception
{
    public int ProductId { get; set; }
    public int RequiredQty { get; set; }
    public int AvailableQty { get; set; }
    public InsufficientStockException(int productId, int required, int available) 
        : base($"Insufficient stock. Required: {required}, Available: {available}")
    {
        ProductId = productId;
        RequiredQty = required;
        AvailableQty = available;
    }
}

public class UnauthorizedOperationException : Exception
{
    public UnauthorizedOperationException(string message) : base(message) { }
}
```

**Updated ExceptionMiddleware:**
```csharp
public async Task InvokeAsync(HttpContext context)
{
    try
    {
        await _next(context);
    }
    catch (Exception ex)
    {
        await HandleExceptionAsync(context, ex);
    }
}

private static Task HandleExceptionAsync(HttpContext context, Exception exception)
{
    context.Response.ContentType = "application/json";

    var response = exception switch
    {
        InsufficientStockException ise => new 
        { 
            status = 400, 
            message = ise.Message, 
            details = new { ise.ProductId, ise.RequiredQty, ise.AvailableQty } 
        },
        InvalidProductException ipe => new { status = 404, message = ipe.Message },
        InvalidOperationException ioe => new { status = 400, message = ioe.Message },
        _ => new { status = 500, message = "Internal server error" }
    };

    context.Response.StatusCode = (int)response.status;
    return context.Response.WriteAsJsonAsync(response);
}
```

### 1.9 Logging Setup (Serilog)
**Add to Program.cs:**
```csharp
Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Debug()
    .WriteTo.Console()
    .WriteTo.File("logs/freshmart-.txt", rollingInterval: RollingInterval.Day)
    .Enrich.FromLogContext()
    .Enrich.WithProperty("Application", "FreshMart Lanka")
    .CreateLogger();

builder.Host.UseSerilog();
```

---

## PHASE 2: ADVANCED FEATURES (Weeks 4-6)
**Goal:** Employee management, reports, stock alerts, image upload.

### 2.1 Employee Management System
- Add IEmployeeService with CRUD operations
- Employee onboarding workflow
- Salary structure (basic, bonus, deductions)
- Document: EmployeesController with role-based access

### 2.2 Attendance Tracking
- Daily check-in/check-out (timestamp-based)
- Attendance reports (monthly, yearly)
- Leave management (optional in Phase 3)

### 2.3 Sales Reports
**Report Types:**
1. **Daily Sales Report**
   - Total orders
   - Total revenue
   - Payment method breakdown
   - Top-selling products

2. **Monthly Sales Summary**
   - Revenue trend
   - Category-wise sales
   - Employee performance (orders count, average order value)

3. **Stock Report**
   - Low stock alerts
   - Stock movement (in/out)
   - Inventory valuation

**Implementation:**
```csharp
[HttpGet("sales/daily")]
[Authorize(Roles = "Admin,Manager")]
public async Task<IActionResult> GetDailySalesReport([FromQuery] DateTime date)
{
    var report = await _reportService.GenerateDailySalesReportAsync(date);
    return Ok(report);
}

[HttpGet("stock-alerts")]
[Authorize(Roles = "Admin,Manager,Warehouse")]
public async Task<IActionResult> GetLowStockAlerts()
{
    var products = await _productService.GetLowStockProductsAsync();
    return Ok(products);
}
```

### 2.4 File Upload (Product Images)
**Setup:**
- Create `/uploads/products` directory
- Implement AppSettings.FileSettings (MaxFileSize, AllowedExtensions)
- Use System.IO for file operations

**Not recommended:** Storing large files in DB (performance impact)

### 2.5 Barcode Search Feature
```csharp
[HttpGet("by-barcode/{barcode}")]
public async Task<IActionResult> GetByBarcode(string barcode)
{
    var product = await _db.Products
        .FirstOrDefaultAsync(p => p.Barcode == barcode);
    
    if (product == null) return NotFound(new { message = "Product not found" });
    return Ok(product);
}
```

---

## PHASE 3: FLUTTER DESKTOP UI IMPLEMENTATION (Weeks 7-9)
**Goal:** Production-grade POS interface + dashboards.

### 3.1 App Architecture (Flutter)
```
lib/
├── screens/
│   ├── login_screen.dart
│   ├── dashboard_screen.dart
│   ├── pos/
│   │   ├── pos_screen.dart          [Main POS]
│   │   ├── cart_screen.dart
│   │   └── payment_screen.dart
│   ├── products/
│   │   ├── products_list_screen.dart
│   │   ├── product_detail_screen.dart
│   │   └── product_form_screen.dart
│   ├── orders/
│   │   ├── orders_list_screen.dart
│   │   └── order_detail_screen.dart
│   ├── employees/
│   │   ├── employees_list_screen.dart
│   │   └── employee_form_screen.dart
│   ├── reports/
│   │   ├── sales_report_screen.dart
│   │   └── stock_report_screen.dart
│   └── admin/
│       ├── admin_dashboard_screen.dart
│       └── user_management_screen.dart
│
├── models/
│   ├── order_model.dart
│   ├── order_item_model.dart
│   ├── employee_model.dart
│   ├── cart_item_model.dart
│   ├── report_model.dart
│   └── user_model.dart
│
├── providers/
│   ├── auth_provider.dart
│   ├── cart_provider.dart            [NEW - Cart state]
│   ├── order_provider.dart           [NEW - Order operations]
│   ├── product_provider.dart         [NEW - Product listing]
│   ├── employee_provider.dart        [NEW - Employee data]
│   └── report_provider.dart          [NEW - Report generation]
│
├── services/
│   ├── api_service.dart              [ENHANCED - All CRUD]
│   ├── local_storage_service.dart
│   └── print_service.dart            [NEW - Receipt printing]
│
├── widgets/
│   ├── common/
│   │   ├── app_bar.dart
│   │   ├── drawer.dart
│   │   └── dialogs.dart
│   ├── pos/
│   │   ├── product_grid.dart
│   │   ├── cart_widget.dart
│   │   ├── barcode_input.dart        [NEW]
│   │   └── receipt_widget.dart       [NEW]
│   └── reports/
│       ├── sales_chart.dart          [NEW]
│       └── table_widget.dart         [NEW]
│
└── main.dart                         [UPDATED]
```

### 3.2 Key Flutter Screens

**POS Screen (Main cashier interface):**
```dart
// Barcode search + product quick-add
// Live cart view with real-time calculations
// Payment processing interface
// Receipt preview & printing
// Quick refund option
```

**Admin Dashboard:**
```dart
// Overview: Total sales, orders, revenue, low stock count
// Quick links: Products, Employees, Reports, Settings
// Recent transactions widget
// Employee attendance widget
```

**Reports Dashboard:**
```dart
// Date range picker
// Charts: Sales trend, category breakdown
// Tables: Daily summary, top products
// Export to CSV (optional)
```

---

## PHASE 4: ANALYTICS & DEPLOYMENT (Weeks 10-12)
### 4.1 Performance Optimization
- Database indexes on frequently queried columns (OrderDate, BarCode, EmployeeId)
- Pagination for large datasets
- Caching for product lists (10-15 min TTL)
- Query optimization (eager loading with Include())

### 4.2 Security Hardening
- HTTPS only in production (remove TrustServerCertificate=True)
- Rate limiting on login & payment APIs
- SQL injection prevention (using EF Core + parameterized queries)
- CSRF protection for form submissions
- Input validation & sanitization
- Secure password storage (already using PasswordHasher)
- JWT token expiration (1 hour recommended)

### 4.3 Scalability Considerations
- Load balancer for multiple API instances
- Database replication for HA
- Implement Repository pattern for data access abstraction
- Async/await throughout (already done)

### 4.4 Deployment Architecture
**Development:** Local SQL Express + localhost API
**Production:**
- Azure AppService / AWS EC2 for API
- Azure SQL Database / AWS RDS for database
- Blob storage for product images
- CDN for static assets
- Docker containerization recommended

---

## PHASE 5: HARDWARE INTEGRATIONS (Optional, External Dependencies)
### These require external libraries and hardware:

**5.1 Barcode Scanner Integration**
- **Status:** Can implement
- **How:** USB HID device communication
- **Package:** [usb] (cross-platform) or platform channels
- **Limitation:** Requires actual scanner hardware; emulation works with keyboard input

**5.2 Receipt Printer Integration**
- **Status:** Can implement
- **How:** Use Windows Print API via WinPrinter package or platform channels
- **Limitation:** Requires thermal printer setup; can implement print-to-PDF as fallback

**5.3 Payment Gateway Integration**
- **Status:** Requires external API
- **Options:** 
  - Stripe (for online payments)
  - PayPal (integration required)
  - Local bank APIs (Sri Lanka: NDB, Standard Chartered, etc.)
- **Limitation:** Requires merchant account setup; cannot implement fully without credentials

---

## WHAT CAN'T BE DONE (Technical Limitations)
1. **Real-time inventory sync across multiple branches** → Requires RabbitMQ/SignalR
2. **Offline POS mode** → Requires local SQLite sync, complex reconciliation logic
3. **Mobile app simultaneous with desktop** → Different platforms, separate development
4. **Credit/debit payment processing** → Requires bank/payment processor integration
5. **Advanced tax compliance (SL VAT)** → Requires tax calculation rules; can be added but needs legal review
6. **Automatic price lookup from barcode database** → Requires GS1 Sri Lanka integration

---

## REALISTIC ROADMAP & TIME ESTIMATES

| Phase | Feature Set | Effort | Timeline | Priority |
|-------|-------------|--------|----------|----------|
| 1 | Core POS, Orders, Clean Architecture | High | 3 weeks | CRITICAL |
| 2 | Employees, Reports, Alerts | Medium | 3 weeks | HIGH |
| 3 | Flutter UI (POS, Dashboards) | High | 3 weeks | HIGH |
| 4 | Deployment, Security, Performance | Medium | 2 weeks | MEDIUM |
| 5 | Hardware Integrations | Low (per item) | 1-2 weeks | OPTIONAL |

**Total Estimated Timeline: 12-14 weeks** (with 1-2 developers)

---

## IMMEDIATE NEXT STEPS

### Week 1 Actions:
1. ✅ Create EF Core migration for Order, OrderItem, Employee, Attendance models
2. ✅ Implement OrderService with transaction-safe order creation
3. ✅ Create OrdersController with validation & error handling
4. ✅ Add EmployeeService (basic CRUD)
5. ✅ Update Program.cs with logging & DI registration

### Development Best Practices:
```csharp
// Always use async/await
public async Task<OrderDto> CreateOrderAsync(...)

// Always validate input
RuleFor(x => x.Items).NotEmpty();

// Always use transactions for multi-step operations
using var transaction = await _db.Database.BeginTransactionAsync();

// Always log important operations
_logger.LogInformation("Order {OrderNo} created", order.OrderNo);

// Always handle specific exceptions
catch (InsufficientStockException ex) { ... }
```

---

## SUCCESS METRICS (Go-Live Checklist)
- [ ] API response time < 200ms for 95th percentile
- [ ] Zero data corruption on order cancellations
- [ ] All endpoints tested with unit + integration tests
- [ ] Logging captures all errors for debugging
- [ ] Dashboard loads in < 2 seconds
- [ ] 99.9% uptime (target)
- [ ] All user roles have proper access control
- [ ] API documentation complete (Swagger UI)
- [ ] Database backups automated daily
- [ ] Security audit completed (OWASP Top 10)

---

## QUESTIONS TO CLARIFY WITH STAKEHOLDERS

1. **Payment Gateway:** Which payment processor? (Local Sri Lankan bank, PayPal, Stripe, Cash-only?)
2. **Multi-branch?** Single location or multiple stores?
3. **Inventory Integration?** Real-time stock levels or manual updates?
4. **Barcode Format?** EAN-13, UPC, or custom barcodes?
5. **Tax Requirements?** VAT, GST, or specific Sri Lankan tax rules?
6. **Backup Strategy?** On-prem, cloud, or hybrid?
7. **Support Plan?** Cost, response time, SLA?

---

## RECOMMENDED TOOLS & LIBRARIES

**Backend:**
- Serilog (structured logging)
- FluentValidation (input validation)
- AutoMapper (DTO mapping, optional)
- Swashbuckle (OpenAPI/Swagger)
- xUnit + Moq (testing)

**Frontend (Flutter):**
- intl (date/time formatting)
- pdf (receipt generation)
- charts_flutter (report visualization)
- fl_chart (alternative charting)
- barcode (barcode generation)

---

**Document Version:** 1.0 (Feb 19, 2026)
**Project:** FreshMart Lanka
**Status:** Implementation Plan Ready

using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Common;
using SupermarketAPI.Models;

namespace SupermarketAPI.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options)
            : base(options)
        {
        }

        public DbSet<Product> Products { get; set; }
        public DbSet<Category> Categories { get; set; }
        public DbSet<User> Users { get; set; }
        public DbSet<Order> Orders { get; set; }
        public DbSet<OrderItem> OrderItems { get; set; }
        public DbSet<Employee> Employees { get; set; }
        public DbSet<Sale> Sales { get; set; }
        public DbSet<SaleItem> SaleItems { get; set; }
        public DbSet<InventoryLog> InventoryLogs { get; set; }
        public DbSet<Notification> Notifications { get; set; }
        public DbSet<Cart> Carts { get; set; }
        public DbSet<CartItem> CartItems { get; set; }
        public DbSet<Supplier> Suppliers { get; set; }
        public DbSet<GoodsReceivedNote> GoodsReceivedNotes { get; set; }
        public DbSet<GoodsReceivedNoteItem> GoodsReceivedNoteItems { get; set; }
        public DbSet<Expense> Expenses { get; set; }
        public DbSet<Payroll> Payrolls { get; set; }
        public DbSet<SalaryAdvance> SalaryAdvances { get; set; }
        public DbSet<PurchaseOrder> PurchaseOrders { get; set; }
        public DbSet<PurchaseOrderItem> PurchaseOrderItems { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                optionsBuilder.UseSqlServer(
                    "Server=localhost\\SQLEXPRESS;Database=SupermarketDB;Trusted_Connection=True;TrustServerCertificate=True;");
            }
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Product>(entity =>
            {
                entity.Property(p => p.Price).HasPrecision(18, 2);
                entity.Property(p => p.CostPrice).HasPrecision(18, 2);
                entity.Property(p => p.Name).IsRequired().HasMaxLength(255);
                entity.Property(p => p.Barcode).HasMaxLength(128);
                entity.HasIndex(p => p.Barcode).IsUnique();
                entity.Property(p => p.ImageUrl).HasMaxLength(1024);
                entity.Property(p => p.Stock).HasDefaultValue(0);
                entity.Property(p => p.LowStockThreshold).HasDefaultValue(5);
                entity.Property(p => p.CreatedAt).HasDefaultValueSql("SYSUTCDATETIME()");
                entity.HasOne(p => p.Category).WithMany().HasForeignKey(p => p.CategoryId).OnDelete(DeleteBehavior.SetNull);
            });

            modelBuilder.Entity<Category>(entity =>
            {
                entity.Property(c => c.Name).IsRequired().HasMaxLength(128);
            });

            modelBuilder.Entity<Expense>(entity =>
            {
                entity.Property(e => e.Amount).HasPrecision(18, 2);
                entity.Property(e => e.Date).HasDefaultValueSql("SYSUTCDATETIME()");
            });

            // Order Configuration (Transaction safety)
            modelBuilder.Entity<Order>(entity =>
            {
                entity.Property(o => o.OrderNo).IsRequired().HasMaxLength(50);
                entity.HasIndex(o => o.OrderNo).IsUnique();
                entity.Property(o => o.TotalAmount).HasPrecision(18, 2);
                entity.Property(o => o.DiscountAmount).HasPrecision(18, 2);
                entity.HasOne(o => o.Employee).WithMany(e => e.Orders).OnDelete(DeleteBehavior.Restrict);
            });

            // OrderItem Configuration
            modelBuilder.Entity<OrderItem>(entity =>
            {
                entity.Property(oi => oi.UnitPrice).HasPrecision(18, 2);
                entity.Property(oi => oi.Discount).HasPrecision(18, 2);
                entity.Property(oi => oi.LineTotal).HasPrecision(18, 2);
                entity.HasOne(oi => oi.Product).WithMany().OnDelete(DeleteBehavior.Restrict);
            });

            // Employee Configuration
            modelBuilder.Entity<Employee>(entity =>
            {
                entity.Property(e => e.Name).IsRequired().HasMaxLength(255);
                entity.Property(e => e.Email).IsRequired().HasMaxLength(255);
                entity.HasIndex(e => e.Email).IsUnique();
                entity.Property(e => e.Phone).HasMaxLength(20);
                entity.Property(e => e.Position).HasMaxLength(100);
                entity.Property(e => e.Salary).HasPrecision(18, 2);
                entity.HasOne(e => e.User).WithMany().OnDelete(DeleteBehavior.Restrict);
            });


            // User configuration
            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique();

            modelBuilder.Entity<User>()
                .Property(u => u.Email)
                .IsRequired()
                .HasMaxLength(255);

            modelBuilder.Entity<User>()
                .Property(u => u.PasswordHash)
                .IsRequired();

            modelBuilder.Entity<User>()
                .Property(u => u.Role)
                .IsRequired()
                .HasMaxLength(50)
                .HasDefaultValue(UserRole.Employee.ToString());

            // Sale Configuration
            modelBuilder.Entity<Sale>(entity =>
            {
                entity.Property(s => s.SaleNo).IsRequired().HasMaxLength(50);
                entity.HasIndex(s => s.SaleNo).IsUnique();
                entity.Property(s => s.TotalAmount).HasPrecision(18, 2);
                entity.Property(s => s.DiscountAmount).HasPrecision(18, 2);
                entity.Property(s => s.PaymentMethod).HasMaxLength(50);
                entity.Property(s => s.Status).HasMaxLength(50);
                entity.Property(s => s.Notes).HasMaxLength(500);
                entity.HasIndex(s => s.SaleDate);
                entity.HasOne(s => s.Employee).WithMany().OnDelete(DeleteBehavior.Restrict);
            });

            // SaleItem Configuration
            modelBuilder.Entity<SaleItem>(entity =>
            {
                entity.Property(si => si.UnitPrice).HasPrecision(18, 2);
                entity.Property(si => si.UnitCost).HasPrecision(18, 2); // Added
                entity.Property(si => si.Discount).HasPrecision(18, 2);
                entity.Property(si => si.LineTotal).HasPrecision(18, 2);
                entity.HasOne(si => si.Product).WithMany().OnDelete(DeleteBehavior.Restrict);
                entity.HasOne(si => si.Sale).WithMany(s => s.SaleItems).OnDelete(DeleteBehavior.Cascade);
            });

            // PurchaseOrder Configuration
            modelBuilder.Entity<PurchaseOrder>(entity =>
            {
                entity.Property(po => po.TotalAmount).HasPrecision(18, 2);
                entity.Property(po => po.Status).HasMaxLength(50);
                entity.HasOne(po => po.Supplier).WithMany().OnDelete(DeleteBehavior.Restrict);
            });

            // PurchaseOrderItem Configuration
            modelBuilder.Entity<PurchaseOrderItem>(entity =>
            {
                entity.Property(poi => poi.UnitCost).HasPrecision(18, 2);
                entity.HasOne(poi => poi.PurchaseOrder).WithMany(po => po.Items).HasForeignKey(poi => poi.PurchaseOrderId).OnDelete(DeleteBehavior.Cascade);
                entity.HasOne(poi => poi.Product).WithMany().OnDelete(DeleteBehavior.Restrict);
            });

            // InventoryLog Configuration
            modelBuilder.Entity<InventoryLog>(entity =>
            {
                entity.Property(il => il.Action).IsRequired().HasMaxLength(50);
                entity.Property(il => il.Reason).HasMaxLength(50);
                entity.Property(il => il.Notes).HasMaxLength(500);
                entity.HasIndex(il => il.ProductId);
                entity.HasIndex(il => il.Timestamp);
                entity.HasOne(il => il.Product).WithMany().OnDelete(DeleteBehavior.Restrict);
                entity.HasOne(il => il.Employee).WithMany().OnDelete(DeleteBehavior.SetNull);
            });

            // Notification Configuration
            modelBuilder.Entity<Notification>(entity =>
            {
                entity.Property(n => n.Title).IsRequired().HasMaxLength(255);
                entity.Property(n => n.Message).IsRequired().HasMaxLength(1000);
                entity.Property(n => n.Type).HasMaxLength(50);
                entity.HasIndex(n => n.EmployeeId);
                entity.HasIndex(n => n.IsRead);
                entity.HasIndex(n => n.CreatedAt);
                entity.HasOne(n => n.Employee).WithMany().OnDelete(DeleteBehavior.Cascade);
            });

            // Additional Indexes for Performance
            modelBuilder.Entity<Order>()
                .HasIndex(o => o.OrderDate);

            modelBuilder.Entity<Cart>(entity =>
            {
                entity.Property(c => c.EmployeeId).IsRequired();
                entity.Property(c => c.CreatedAt).HasDefaultValueSql("SYSUTCDATETIME()");
                entity.HasMany(c => c.Items).WithOne().HasForeignKey(ci => ci.CartId).OnDelete(DeleteBehavior.Cascade);
            });

            modelBuilder.Entity<CartItem>(entity =>
            {
                entity.Property(ci => ci.Quantity).HasDefaultValue(1);
                entity.Property(ci => ci.UnitPrice).HasPrecision(18,2);
                entity.HasIndex(ci => ci.ProductId);
            });

            modelBuilder.Entity<Product>()
                .HasIndex(p => p.CategoryId);

            modelBuilder.Entity<Employee>()
                .HasIndex(e => e.UserId);
        }
    }
}

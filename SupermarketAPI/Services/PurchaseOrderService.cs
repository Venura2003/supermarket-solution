using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;
using SupermarketAPI.DTOs;
using SupermarketAPI.Models;

namespace SupermarketAPI.Services
{
    public class PurchaseOrderService : IPurchaseOrderService
    {
        private readonly AppDbContext _db;

        public PurchaseOrderService(AppDbContext db)
        {
            _db = db;
        }

        public async Task<IEnumerable<PurchaseOrderDto>> GetAllAsync()
        {
            return await _db.PurchaseOrders
                .Include(po => po.Supplier)
                .Include(po => po.Items)
                .ThenInclude(i => i.Product)
                .Select(po => new PurchaseOrderDto
                {
                    Id = po.Id,
                    SupplierId = po.SupplierId,
                    SupplierName = po.Supplier != null ? po.Supplier.Name : "Unknown",
                    OrderDate = po.OrderDate,
                    Status = po.Status,
                    TotalAmount = po.TotalAmount,
                    Items = po.Items.Select(i => new PurchaseOrderItemDto
                    {
                        Id = i.Id,
                        ProductId = i.ProductId,
                        ProductName = i.Product != null ? i.Product.Name : "Unknown",
                        Quantity = i.Quantity,
                        UnitCost = i.UnitCost
                    }).ToList()
                })
                .ToListAsync();
        }

        public async Task<PurchaseOrderDto> GetByIdAsync(int id)
        {
            var po = await _db.PurchaseOrders
                .Include(po => po.Supplier)
                .Include(po => po.Items)
                .ThenInclude(i => i.Product)
                .FirstOrDefaultAsync(p => p.Id == id);

            if (po == null) return null;

            return new PurchaseOrderDto
            {
                Id = po.Id,
                SupplierId = po.SupplierId,
                SupplierName = po.Supplier?.Name ?? "Unknown",
                OrderDate = po.OrderDate,
                Status = po.Status,
                TotalAmount = po.TotalAmount,
                Items = po.Items.Select(i => new PurchaseOrderItemDto
                {
                    Id = i.Id,
                    ProductId = i.ProductId,
                    ProductName = i.Product?.Name ?? "Unknown",
                    Quantity = i.Quantity,
                    UnitCost = i.UnitCost
                }).ToList()
            };
        }

        public async Task<PurchaseOrderDto> CreateAsync(CreatePurchaseOrderDto dto)
        {
            var po = new PurchaseOrder
            {
                SupplierId = dto.SupplierId,
                OrderDate = DateTime.UtcNow,
                Status = "Pending",
                TotalAmount = dto.Items.Sum(i => i.Quantity * i.UnitCost),
                Items = dto.Items.Select(i => new PurchaseOrderItem
                {
                    ProductId = i.ProductId,
                    Quantity = i.Quantity,
                    UnitCost = i.UnitCost
                }).ToList()
            };

            _db.PurchaseOrders.Add(po);
            await _db.SaveChangesAsync();

            return await GetByIdAsync(po.Id);
        }

        public async Task<PurchaseOrderDto> ReceiveOrderAsync(int id)
        {
            var po = await _db.PurchaseOrders
                .Include(po => po.Items)
                .FirstOrDefaultAsync(p => p.Id == id);

            if (po == null) throw new Exception("Purchase Order not found");
            if (po.Status == "Received") throw new Exception("Purchase Order already received");

            using var transaction = await _db.Database.BeginTransactionAsync();
            try
            {
                po.Status = "Received";

                // Create GRN
                var grn = new GoodsReceivedNote
                {
                    SupplierId = po.SupplierId,
                    ReceivedDate = DateTime.UtcNow,
                    TotalAmount = po.TotalAmount,
                    Notes = $"Purchase Order #{po.Id}",
                    Items = po.Items.Select(i => new GoodsReceivedNoteItem
                    {
                        ProductId = i.ProductId,
                        Quantity = i.Quantity,
                        UnitCost = i.UnitCost,
                        TotalCost = i.Quantity * i.UnitCost
                    }).ToList()
                };

                _db.GoodsReceivedNotes.Add(grn);

                // Update Stock
                foreach (var item in po.Items)
                {
                    var product = await _db.Products.FindAsync(item.ProductId);
                    if (product != null)
                    {
                        product.Stock += item.Quantity;
                        product.CostPrice = item.UnitCost; // Update current cost price
                        _db.InventoryLogs.Add(new InventoryLog
                        {
                            ProductId = item.ProductId,
                            Quantity = item.Quantity,
                            Action = "StockIn",
                            Reason = $"PO Received #{po.Id}",
                            Timestamp = DateTime.UtcNow,
                            Notes = $"Updated via PO #{po.Id}"
                        });
                    }
                }

                await _db.SaveChangesAsync();
                await transaction.CommitAsync();

                return await GetByIdAsync(id);
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }
        }
    }
}

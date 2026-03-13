using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;
using SupermarketAPI.DTOs;
using SupermarketAPI.Models;

namespace SupermarketAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class GrnController : ControllerBase
    {
        private readonly AppDbContext _context;

        public GrnController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/Grn
        [HttpGet]
        public async Task<ActionResult<IEnumerable<object>>> GetGrns()
        {
            return await _context.GoodsReceivedNotes
                .Include(g => g.Supplier)
                .Include(g => g.Items)
                .ThenInclude(i => i.Product)
                .OrderByDescending(g => g.ReceivedDate)
                .Select(g => new {
                    g.Id,
                    g.ReceivedDate,
                    g.TotalAmount,
                    SupplierName = g.Supplier != null ? g.Supplier.Name : "Unknown",
                    ItemsCount = g.Items.Count
                })
                .ToListAsync();
        }

        // GET: api/Grn/5
        [HttpGet("{id}")]
        public async Task<ActionResult<object>> GetGrn(int id)
        {
            var grn = await _context.GoodsReceivedNotes
                .Include(g => g.Supplier)
                .Include(g => g.Items)
                .ThenInclude(i => i.Product)
                .FirstOrDefaultAsync(g => g.Id == id);

            if (grn == null)
            {
                return NotFound();
            }

            return new {
                grn.Id,
                grn.ReceivedDate,
                grn.TotalAmount,
                grn.Notes,
                Supplier = grn.Supplier,
                Items = grn.Items.Select(i => new {
                    i.Id,
                    ProductName = i.Product?.Name ?? "Unknown",
                    i.Quantity,
                    i.UnitCost,
                    i.TotalCost
                })
            };
        }

        // POST: api/Grn
        [HttpPost]
        public async Task<ActionResult<GoodsReceivedNote>> PostGrn(CreateGRNDto dto)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                var grn = new GoodsReceivedNote
                {
                    SupplierId = dto.SupplierId,
                    ReceivedDate = DateTime.UtcNow,
                    Notes = dto.Notes,
                    Items = new List<GoodsReceivedNoteItem>()
                };

                decimal totalGrnAmount = 0;

                foreach (var itemDto in dto.Items)
                {
                    var product = await _context.Products.FindAsync(itemDto.ProductId);
                    if (product == null) continue;

                    var itemTotalCost = itemDto.Quantity * itemDto.UnitCost;
                    totalGrnAmount += itemTotalCost;

                    var grnItem = new GoodsReceivedNoteItem
                    {
                        ProductId = itemDto.ProductId,
                        Quantity = itemDto.Quantity,
                        UnitCost = itemDto.UnitCost,
                        TotalCost = itemTotalCost
                    };
                    grn.Items.Add(grnItem);

                    // Update Stock
                    product.Stock += itemDto.Quantity;
                    
                    // Allow updating selling price if provided
                    if (itemDto.NewSellingPrice.HasValue && itemDto.NewSellingPrice.Value > 0)
                    {
                        product.Price = itemDto.NewSellingPrice.Value;
                    }

                    _context.Products.Update(product);
                }

                grn.TotalAmount = totalGrnAmount;

                _context.GoodsReceivedNotes.Add(grn);
                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                return CreatedAtAction("GetGrn", new { id = grn.Id }, grn);
            }
            catch (Exception)
            {
                await transaction.RollbackAsync();
                throw;
            }
        }
    }
}

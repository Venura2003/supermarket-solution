using SupermarketAPI.Data;

namespace SupermarketAPI.Services
{
    public interface IUnitOfWork : IDisposable
    {
        IProductService Products { get; }
        IOrderService Orders { get; }
        ISaleService Sales { get; }
        IEmployeeService Employees { get; }
        ICategoryService Categories { get; }
        Task<int> SaveChangesAsync();
        Task BeginTransactionAsync();
        Task CommitTransactionAsync();
        Task RollbackTransactionAsync();
    }

    public class UnitOfWork : IUnitOfWork
    {
        private readonly AppDbContext _context;
        private readonly ILoggerFactory _loggerFactory;
        private IProductService? _products;
        private IOrderService? _orders;
        private ISaleService? _sales;
        private IEmployeeService? _employees;
        private ICategoryService? _categories;

        public UnitOfWork(AppDbContext context, ILoggerFactory loggerFactory)
        {
            _context = context;
            _loggerFactory = loggerFactory;
        }

        public IProductService Products => _products ??= new ProductService(_context, _loggerFactory.CreateLogger<ProductService>());
        public IOrderService Orders => _orders ??= new OrderService(_context, _loggerFactory.CreateLogger<OrderService>());
        public ISaleService Sales => _sales ??= new SaleService(_context, this, _loggerFactory.CreateLogger<SaleService>());
        public IEmployeeService Employees => _employees ??= new EmployeeService(_context, _loggerFactory.CreateLogger<EmployeeService>());
        public ICategoryService Categories => _categories ??= new CategoryService(_context, _loggerFactory.CreateLogger<CategoryService>());

        public async Task<int> SaveChangesAsync()
        {
            return await _context.SaveChangesAsync();
        }

        public async Task BeginTransactionAsync()
        {
            await _context.Database.BeginTransactionAsync();
        }

        public async Task CommitTransactionAsync()
        {
            await _context.Database.CommitTransactionAsync();
        }

        public async Task RollbackTransactionAsync()
        {
            await _context.Database.RollbackTransactionAsync();
        }

        public void Dispose()
        {
            _context.Dispose();
        }
    }
}
namespace SupermarketAPI.Common.Exceptions
{
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
            : base($"Insufficient stock for product {productId}. Required: {required}, Available: {available}")
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

    public class OrderException : Exception
    {
        public OrderException(string message) : base(message) { }
    }

    public class EmployeeException : Exception
    {
        public EmployeeException(string message) : base(message) { }
    }
}

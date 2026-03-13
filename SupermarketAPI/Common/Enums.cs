namespace SupermarketAPI.Common
{
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


    public enum UserRole
    {
        Admin,        // Full system access
        Manager,      // Reports & employee management
        Cashier,      // POS & order creation
        Warehouse,    // Stock & inventory
        Employee      // Basic access
    }

    public enum InventoryAction
    {
        StockIn,      // Adding stock
        StockOut,     // Removing stock (sale)
        Adjustment,   // Manual adjustment
        Return,       // Customer return
        Damaged       // Damaged goods
    }

    public enum PayrollStatus
    {
        Draft,
        Approved,
        Paid
    }
}

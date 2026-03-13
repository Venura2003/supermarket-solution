using System.Threading.Tasks;

namespace SupermarketAPI.Services
{
    // Lightweight stub - replace with real gateway integration (Stripe/PayPal)
    public class PaymentService : IPaymentService
    {
        public Task<PaymentResult> ProcessPaymentAsync(decimal amount, string method, object? details = null)
        {
            // For now, simulate success for 'Cash' and 'Card' with mock transaction id
            var result = new PaymentResult
            {
                Success = true,
                TransactionId = $"TXN-{System.Guid.NewGuid():N}",
                Message = "Mock payment processed"
            };

            return Task.FromResult(result);
        }
    }
}

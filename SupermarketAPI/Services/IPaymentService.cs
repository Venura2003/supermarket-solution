using System.Threading.Tasks;

namespace SupermarketAPI.Services
{
    public class PaymentResult
    {
        public bool Success { get; set; }
        public string? TransactionId { get; set; }
        public string? Message { get; set; }
    }

    public interface IPaymentService
    {
        Task<PaymentResult> ProcessPaymentAsync(decimal amount, string method, object? details = null);
    }
}

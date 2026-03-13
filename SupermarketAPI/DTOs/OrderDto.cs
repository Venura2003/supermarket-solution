using System.Text.Json.Serialization;

namespace SupermarketAPI.DTOs
{
    public record CreateOrderItemDto(
        [property: JsonPropertyName("productId")] int ProductId,
        [property: JsonPropertyName("quantity")] int Quantity,
        [property: JsonPropertyName("customDiscount")] decimal? CustomDiscount = null
    );

    public record CreateOrderDto(
        [property: JsonPropertyName("items")] List<CreateOrderItemDto> Items,
        [property: JsonPropertyName("discount")] decimal Discount = 0,
        [property: JsonPropertyName("paymentMethod")] string PaymentMethod = "Cash",
        [property: JsonPropertyName("notes")] string Notes = ""
    );

    public record OrderItemDto(
        int Id,
        int ProductId,
        string ProductName,
        int Quantity,
        decimal UnitPrice,
        decimal Discount,
        decimal LineTotal
    );

    public record OrderDto(
        int Id,
        string OrderNo,
        int EmployeeId,
        string EmployeeName,
        DateTime OrderDate,
        decimal TotalAmount,
        decimal DiscountAmount,
        string PaymentMethod,
        string Status,
        List<OrderItemDto> Items
    );

    public record OrderFilterDto(
        DateTime? StartDate = null,
        DateTime? EndDate = null,
        string? PaymentMethod = null,
        string? Status = null,
        int PageNumber = 1,
        int PageSize = 50
    );
}

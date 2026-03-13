namespace SupermarketAPI.DTOs
{
    public record ProductDto(
        int Id,
        string Name,
        int? CategoryId,
        string? Barcode,
        string? ImageUrl,
        decimal Price,
        int Stock,
        int LowStockThreshold,
        System.DateTime CreatedAt
    );
}

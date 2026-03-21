namespace SupermarketAPI.DTOs
{
    public record CreateCategoryDto(
        string Name,
        string? ImageUrl
    );
}

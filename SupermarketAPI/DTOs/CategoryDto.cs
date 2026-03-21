namespace SupermarketAPI.DTOs
{
    public record CategoryDto(
        int Id,
        string Name,
        string? ImageUrl
    );
}

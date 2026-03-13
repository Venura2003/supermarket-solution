namespace SupermarketAPI.DTOs
{
    public record CreateEmployeeDto(
        int? UserId,
        string Name,
        string Email,
        string Phone,
        string Position,
        decimal Salary,
        DateTime HireDate
    );

    public record UpdateEmployeeDto(
        int? UserId,
        string Name,
        string Email,
        string Phone,
        string Position,
        decimal Salary,
        bool IsActive
    );

    public record EmployeeDto(
        int Id,
        int? UserId,
        string Name,
        string Email,
        string Phone,
        string Position,
        decimal Salary,
        DateTime HireDate,
        string Role,
        string? Username,
        bool IsActive,
        DateTime CreatedAt
    );

    public record EmployeeFilterDto(
        bool? IsActive = true,
        int PageNumber = 1,
        int PageSize = 50
    );
}

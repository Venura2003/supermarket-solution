using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SupermarketAPI.Migrations
{
    /// <inheritdoc />
    public partial class AddMissingEmployeeColumns : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Add IsActive column if it doesn't exist
            migrationBuilder.Sql(@"
                IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Employees') AND name = 'IsActive')
                BEGIN
                    ALTER TABLE Employees ADD IsActive BIT NOT NULL DEFAULT 1;
                END
            ");

            // Add Phone column if it doesn't exist
            migrationBuilder.Sql(@"
                IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Employees') AND name = 'Phone')
                BEGIN
                    ALTER TABLE Employees ADD Phone NVARCHAR(20) NOT NULL DEFAULT '';
                END
            ");

            // Add Position column if it doesn't exist
            migrationBuilder.Sql(@"
                IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Employees') AND name = 'Position')
                BEGIN
                    ALTER TABLE Employees ADD Position NVARCHAR(100) NOT NULL DEFAULT '';
                END
            ");

            // Add CreatedAt column if it doesn't exist
            migrationBuilder.Sql(@"
                IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Employees') AND name = 'CreatedAt')
                BEGIN
                    ALTER TABLE Employees ADD CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE();
                END
            ");

            // Add UpdatedAt column if it doesn't exist
            migrationBuilder.Sql(@"
                IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Employees') AND name = 'UpdatedAt')
                BEGIN
                    ALTER TABLE Employees ADD UpdatedAt DATETIME2 NULL;
                END
            ");
            
            // Re-check Salary and HireDate just in case
            migrationBuilder.Sql(@"
                IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Employees') AND name = 'Salary')
                BEGIN
                    ALTER TABLE Employees ADD Salary DECIMAL(18,2) NULL;
                END
            ");

            migrationBuilder.Sql(@"
                IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Employees') AND name = 'HireDate')
                BEGIN
                    ALTER TABLE Employees ADD HireDate DATETIME2 NULL;
                END
            ");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {

        }
    }
}

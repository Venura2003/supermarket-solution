using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SupermarketAPI.Migrations
{
    /// <inheritdoc />
    public partial class PendingModelChanges : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE Name = N'Username' AND Object_ID = OBJECT_ID(N'[Employees]')
)
BEGIN
    DECLARE @var nvarchar(max);
    SELECT @var = QUOTENAME(d.name)
    FROM sys.default_constraints d
    INNER JOIN sys.columns c ON d.parent_column_id = c.column_id AND d.parent_object_id = c.object_id
    WHERE (d.parent_object_id = OBJECT_ID(N'[Employees]') AND c.name = N'Username');
    IF @var IS NOT NULL EXEC(N'ALTER TABLE [Employees] DROP CONSTRAINT ' + @var + ';');
    ALTER TABLE [Employees] DROP COLUMN [Username];
END");

            migrationBuilder.AddColumn<string>(
                name: "Username",
                table: "Users",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE Name = N'Username' AND Object_ID = OBJECT_ID(N'[Users]')
)
BEGIN
    DECLARE @var nvarchar(max);
    SELECT @var = QUOTENAME(d.name)
    FROM sys.default_constraints d
    INNER JOIN sys.columns c ON d.parent_column_id = c.column_id AND d.parent_object_id = c.object_id
    WHERE (d.parent_object_id = OBJECT_ID(N'[Users]') AND c.name = N'Username');
    IF @var IS NOT NULL EXEC(N'ALTER TABLE [Users] DROP CONSTRAINT ' + @var + ';');
    ALTER TABLE [Users] DROP COLUMN [Username];
END");

            migrationBuilder.Sql(@"IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE Name = N'Username' AND Object_ID = OBJECT_ID(N'[Employees]')
)
BEGIN
    ALTER TABLE [Employees] ADD [Username] nvarchar(100) NULL;
END");
        }
    }
}

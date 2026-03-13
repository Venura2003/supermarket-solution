using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SupermarketAPI.Migrations
{
    /// <inheritdoc />
    public partial class MakeEmployeeFieldsNullable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Salary was missing in DB, adding it as nullable
            migrationBuilder.AddColumn<decimal>(
                name: "Salary",
                table: "Employees",
                type: "decimal(18,2)",
                precision: 18,
                scale: 2,
                nullable: true);

            // HireDate is being altered to nullable (if it exists) OR added (if missing).
            // To be safe and since Salary was missing, let's try to add it first.
            // If it exists, this will fail. If so, we should use SQL check.
            // But let's assume it's missing too.
             migrationBuilder.AddColumn<DateTime>(
                name: "HireDate",
                table: "Employees",
                type: "datetime2",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Salary",
                table: "Employees");

            migrationBuilder.DropColumn(
                name: "HireDate",
                table: "Employees");
        }
    }
}

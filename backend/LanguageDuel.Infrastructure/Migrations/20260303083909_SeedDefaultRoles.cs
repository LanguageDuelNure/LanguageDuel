using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable


namespace LanguageDuel.Infrastructure.Migrations;

/// <inheritdoc />
public partial class SeedDefaultRoles : Migration
{
    /// <inheritdoc />
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.InsertData(
            table: "AspNetRoles",
            columns: ["Id", "ConcurrencyStamp", "Name", "NormalizedName"],
            values: new object[,]
            {
                { "1", null, "User", "USER" },
                { "2", null, "Admin", "ADMIN" }
            });
    }

    /// <inheritdoc />
    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DeleteData(
            table: "AspNetRoles",
            keyColumn: "Id",
            keyValue: "1");

        migrationBuilder.DeleteData(
            table: "AspNetRoles",
            keyColumn: "Id",
            keyValue: "2");
    }
}

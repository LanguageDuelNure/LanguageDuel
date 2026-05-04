using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace LanguageDuel.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddIsWinColumnForGameApplicationUser : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsWin",
                table: "GameApplicationUsers",
                type: "tinyint(1)",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsWin",
                table: "GameApplicationUsers");
        }
    }
}

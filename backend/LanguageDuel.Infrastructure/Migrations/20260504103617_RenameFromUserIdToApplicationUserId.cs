using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace LanguageDuel.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class RenameFromUserIdToApplicationUserId : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "UserId",
                table: "Tickets",
                newName: "ApplicationUserId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "ApplicationUserId",
                table: "Tickets",
                newName: "UserId");
        }
    }
}

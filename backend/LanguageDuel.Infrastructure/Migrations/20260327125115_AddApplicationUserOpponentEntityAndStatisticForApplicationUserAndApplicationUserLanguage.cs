using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace LanguageDuel.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddApplicationUserOpponentEntityAndStatisticForApplicationUserAndApplicationUserLanguage : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "TotalGames",
                table: "AspNetUsers",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "TotalWins",
                table: "AspNetUsers",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "MaxRating",
                table: "ApplicationUserLanguages",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "TotalGames",
                table: "ApplicationUserLanguages",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "TotalWins",
                table: "ApplicationUserLanguages",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateTable(
                name: "ApplicationUserOpponents",
                columns: table => new
                {
                    ApplicationUserId = table.Column<Guid>(type: "char(36)", nullable: false, collation: "ascii_general_ci"),
                    OpponentId = table.Column<Guid>(type: "char(36)", nullable: false, collation: "ascii_general_ci"),
                    MatchesPlayed = table.Column<int>(type: "int", nullable: false),
                    LastPlayedAt = table.Column<DateTime>(type: "datetime(6)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ApplicationUserOpponents", x => new { x.ApplicationUserId, x.OpponentId });
                    table.ForeignKey(
                        name: "FK_ApplicationUserOpponents_AspNetUsers_ApplicationUserId",
                        column: x => x.ApplicationUserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ApplicationUserOpponents_AspNetUsers_OpponentId",
                        column: x => x.OpponentId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateIndex(
                name: "IX_ApplicationUserOpponents_OpponentId",
                table: "ApplicationUserOpponents",
                column: "OpponentId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ApplicationUserOpponents");

            migrationBuilder.DropColumn(
                name: "TotalGames",
                table: "AspNetUsers");

            migrationBuilder.DropColumn(
                name: "TotalWins",
                table: "AspNetUsers");

            migrationBuilder.DropColumn(
                name: "MaxRating",
                table: "ApplicationUserLanguages");

            migrationBuilder.DropColumn(
                name: "TotalGames",
                table: "ApplicationUserLanguages");

            migrationBuilder.DropColumn(
                name: "TotalWins",
                table: "ApplicationUserLanguages");
        }
    }
}

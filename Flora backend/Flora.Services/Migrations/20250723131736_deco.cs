using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Flora.Services.Migrations
{
    /// <inheritdoc />
    public partial class deco : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "DecorationRequests",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    EventType = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    EventDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    VenueType = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    NumberOfGuests = table.Column<int>(type: "int", nullable: false),
                    NumberOfTables = table.Column<int>(type: "int", nullable: false),
                    ThemeOrColors = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Location = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    SpecialRequests = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Budget = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    UserId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DecorationRequests", x => x.Id);
                    table.ForeignKey(
                        name: "FK_DecorationRequests_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "DecorationSuggestions",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    DecorationRequestId = table.Column<int>(type: "int", nullable: false),
                    ImageUrl = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DecorationSuggestions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_DecorationSuggestions_DecorationRequests_DecorationRequestId",
                        column: x => x.DecorationRequestId,
                        principalTable: "DecorationRequests",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_DecorationRequests_UserId",
                table: "DecorationRequests",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_DecorationSuggestions_DecorationRequestId",
                table: "DecorationSuggestions",
                column: "DecorationRequestId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "DecorationSuggestions");

            migrationBuilder.DropTable(
                name: "DecorationRequests");
        }
    }
}

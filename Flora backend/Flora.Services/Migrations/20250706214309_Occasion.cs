using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Flora.Services.Migrations
{
    /// <inheritdoc />
    public partial class Occasion : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsFeatured",
                table: "Products",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "IsNew",
                table: "Products",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<int>(
                name: "OccasionId",
                table: "Products",
                type: "int",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "Occasion",
                columns: table => new
                {
                    OccasionId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Occasion", x => x.OccasionId);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Products_OccasionId",
                table: "Products",
                column: "OccasionId");

            migrationBuilder.AddForeignKey(
                name: "FK_Products_Occasion_OccasionId",
                table: "Products",
                column: "OccasionId",
                principalTable: "Occasion",
                principalColumn: "OccasionId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Products_Occasion_OccasionId",
                table: "Products");

            migrationBuilder.DropTable(
                name: "Occasion");

            migrationBuilder.DropIndex(
                name: "IX_Products_OccasionId",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "IsFeatured",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "IsNew",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "OccasionId",
                table: "Products");
        }
    }
}

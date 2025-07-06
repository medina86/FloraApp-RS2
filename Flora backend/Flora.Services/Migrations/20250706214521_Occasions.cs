using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace Flora.Services.Migrations
{
    /// <inheritdoc />
    public partial class Occasions : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Products_Occasion_OccasionId",
                table: "Products");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Occasion",
                table: "Occasion");

            migrationBuilder.RenameTable(
                name: "Occasion",
                newName: "Occasions");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Occasions",
                table: "Occasions",
                column: "OccasionId");

            migrationBuilder.InsertData(
                table: "Occasions",
                columns: new[] { "OccasionId", "Name" },
                values: new object[,]
                {
                    { 1, "Birthday" },
                    { 2, "Weeding" },
                    { 3, "Graduation" }
                });

            migrationBuilder.AddForeignKey(
                name: "FK_Products_Occasions_OccasionId",
                table: "Products",
                column: "OccasionId",
                principalTable: "Occasions",
                principalColumn: "OccasionId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Products_Occasions_OccasionId",
                table: "Products");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Occasions",
                table: "Occasions");

            migrationBuilder.DeleteData(
                table: "Occasions",
                keyColumn: "OccasionId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Occasions",
                keyColumn: "OccasionId",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Occasions",
                keyColumn: "OccasionId",
                keyValue: 3);

            migrationBuilder.RenameTable(
                name: "Occasions",
                newName: "Occasion");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Occasion",
                table: "Occasion",
                column: "OccasionId");

            migrationBuilder.AddForeignKey(
                name: "FK_Products_Occasion_OccasionId",
                table: "Products",
                column: "OccasionId",
                principalTable: "Occasion",
                principalColumn: "OccasionId");
        }
    }
}

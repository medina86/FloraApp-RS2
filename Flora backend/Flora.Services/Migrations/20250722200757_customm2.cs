using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Flora.Services.Migrations
{
    /// <inheritdoc />
    public partial class customm2 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "CustomBouquetId",
                table: "OrderDetails",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_OrderDetails_CustomBouquetId",
                table: "OrderDetails",
                column: "CustomBouquetId");

            migrationBuilder.AddForeignKey(
                name: "FK_OrderDetails_CustomBouquets_CustomBouquetId",
                table: "OrderDetails",
                column: "CustomBouquetId",
                principalTable: "CustomBouquets",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_OrderDetails_CustomBouquets_CustomBouquetId",
                table: "OrderDetails");

            migrationBuilder.DropIndex(
                name: "IX_OrderDetails_CustomBouquetId",
                table: "OrderDetails");

            migrationBuilder.DropColumn(
                name: "CustomBouquetId",
                table: "OrderDetails");
        }
    }
}

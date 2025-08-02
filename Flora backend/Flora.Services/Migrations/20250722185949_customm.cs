using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Flora.Services.Migrations
{
    /// <inheritdoc />
    public partial class customm : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_CartItems_Products_ProductId",
                table: "CartItems");

            migrationBuilder.AlterColumn<int>(
                name: "ProductId",
                table: "CartItems",
                type: "int",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.AddColumn<int>(
                name: "CustomBouquetId",
                table: "CartItems",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_CartItems_CustomBouquetId",
                table: "CartItems",
                column: "CustomBouquetId");

            migrationBuilder.AddForeignKey(
                name: "FK_CartItems_CustomBouquets_CustomBouquetId",
                table: "CartItems",
                column: "CustomBouquetId",
                principalTable: "CustomBouquets",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_CartItems_Products_ProductId",
                table: "CartItems",
                column: "ProductId",
                principalTable: "Products",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_CartItems_CustomBouquets_CustomBouquetId",
                table: "CartItems");

            migrationBuilder.DropForeignKey(
                name: "FK_CartItems_Products_ProductId",
                table: "CartItems");

            migrationBuilder.DropIndex(
                name: "IX_CartItems_CustomBouquetId",
                table: "CartItems");

            migrationBuilder.DropColumn(
                name: "CustomBouquetId",
                table: "CartItems");

            migrationBuilder.AlterColumn<int>(
                name: "ProductId",
                table: "CartItems",
                type: "int",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "int",
                oldNullable: true);

            migrationBuilder.AddForeignKey(
                name: "FK_CartItems_Products_ProductId",
                table: "CartItems",
                column: "ProductId",
                principalTable: "Products",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}

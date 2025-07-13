using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Flora.Services.Migrations
{
    /// <inheritdoc />
    public partial class categoryImage : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "CategorymageUrl",
                table: "Categories",
                type: "nvarchar(max)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CategorymageUrl",
                table: "Categories");
        }
    }
}

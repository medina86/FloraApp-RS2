using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Flora.Services.Migrations
{
    /// <inheritdoc />
    public partial class update : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<decimal>(
                name: "TotalAmount",
                table: "DonationCampaigns",
                type: "decimal(18,2)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.UpdateData(
                table: "DonationCampaigns",
                keyColumn: "Id",
                keyValue: 1,
                column: "TotalAmount",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "DonationCampaigns",
                keyColumn: "Id",
                keyValue: 2,
                column: "TotalAmount",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "DonationCampaigns",
                keyColumn: "Id",
                keyValue: 3,
                column: "TotalAmount",
                value: 0m);

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2025, 8, 21, 12, 33, 57, 133, DateTimeKind.Utc).AddTicks(8287), "1DYDCHFbeqQIq0GVr8itVEiQ387/fv3QT3fiRm+lWAc=", "Of0phUJHn47cfDbtB1xXKg==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2025, 8, 21, 12, 33, 57, 133, DateTimeKind.Utc).AddTicks(8291), "CwfSHadpULY2qBu52teAwqiOXQJiKeWD/Fc/2Ht7WKM=", "2xrjDT87fF+nK2dKS0GdZg==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2025, 8, 21, 12, 33, 57, 133, DateTimeKind.Utc).AddTicks(8294), "1bcl2+a/nCH9yw4O+dE2tIFfqSjNwoUwQki5FkDSSvY=", "4r94XhCARl1PChd3Ay7s+A==" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "TotalAmount",
                table: "DonationCampaigns");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2025, 8, 7, 16, 8, 16, 842, DateTimeKind.Utc).AddTicks(4108), "qDwRm1Je9uV+OOVzUkx39yVc6kwX7kHXghsphGzASt8=", "XN5np4S0VzWNtZLrR/NTQg==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2025, 8, 7, 16, 8, 16, 842, DateTimeKind.Utc).AddTicks(4114), "gX/yzzWNl+5dUWP7r+SoKS/4oWbaLISB07DQtz6PfMU=", "RqPOpvr8F7P+yM9Giv+K0w==" });

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "CreatedAt", "PasswordHash", "PasswordSalt" },
                values: new object[] { new DateTime(2025, 8, 7, 16, 8, 16, 842, DateTimeKind.Utc).AddTicks(4116), "uzCHhrGT3SlTTIK9h8fFYUfs7Nxzg59xwhqW/z7Dz6Q=", "YXKd1kb3lhk3uTvfEo5L7Q==" });
        }
    }
}

using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace Flora.Services.Migrations
{
    /// <inheritdoc />
    public partial class DonationResponse2 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "BlogPosts",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Title = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Content = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_BlogPosts", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Carts",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Carts", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Categories",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    CategoryImageUrl = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Categories", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "DonationCampaigns",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Title = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    EndDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    ImageUrl = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DonationCampaigns", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Occasions",
                columns: table => new
                {
                    OccasionId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Occasions", x => x.OccasionId);
                });

            migrationBuilder.CreateTable(
                name: "Roles",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Roles", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "ShippingAddresses",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    FirstName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    LastName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    City = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Street = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    HouseNumber = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    PostalCode = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    OrderNote = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ShippingAddresses", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Users",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    FirstName = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    LastName = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Email = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Username = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    PasswordHash = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    PasswordSalt = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    LastLoginAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    PhoneNumber = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: true),
                    ProfileImageUrl = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Users", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "BlogImages",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Url = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    BlogPostId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_BlogImages", x => x.Id);
                    table.ForeignKey(
                        name: "FK_BlogImages_BlogPosts_BlogPostId",
                        column: x => x.BlogPostId,
                        principalTable: "BlogPosts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Products",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Price = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    CategoryId = table.Column<int>(type: "int", nullable: true),
                    IsNew = table.Column<bool>(type: "bit", nullable: false),
                    IsFeatured = table.Column<bool>(type: "bit", nullable: false),
                    OccasionId = table.Column<int>(type: "int", nullable: true),
                    Active = table.Column<bool>(type: "bit", nullable: false),
                    IsAvailable = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Products", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Products_Categories_CategoryId",
                        column: x => x.CategoryId,
                        principalTable: "Categories",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_Products_Occasions_OccasionId",
                        column: x => x.OccasionId,
                        principalTable: "Occasions",
                        principalColumn: "OccasionId");
                });

            migrationBuilder.CreateTable(
                name: "Orders",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    OrderDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    TotalAmount = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    Status = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    ShippingAddressId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Orders", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Orders_ShippingAddresses_ShippingAddressId",
                        column: x => x.ShippingAddressId,
                        principalTable: "ShippingAddresses",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "BlogComments",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    AuthorName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Content = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    BlogPostId = table.Column<int>(type: "int", nullable: false),
                    UserId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_BlogComments", x => x.Id);
                    table.ForeignKey(
                        name: "FK_BlogComments_BlogPosts_BlogPostId",
                        column: x => x.BlogPostId,
                        principalTable: "BlogPosts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_BlogComments_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "CustomBouquets",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Color = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CardMessage = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SpecialInstructions = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    TotalPrice = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    UserId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CustomBouquets", x => x.Id);
                    table.ForeignKey(
                        name: "FK_CustomBouquets_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

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
                name: "Donations",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    DonorName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Email = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Amount = table.Column<double>(type: "float", nullable: false),
                    Purpose = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Date = table.Column<DateTime>(type: "datetime2", nullable: false),
                    TransactionId = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Status = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CampaignId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Donations", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Donations_DonationCampaigns_CampaignId",
                        column: x => x.CampaignId,
                        principalTable: "DonationCampaigns",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Donations_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "UserRoles",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    RoleId = table.Column<int>(type: "int", nullable: false),
                    DateAssigned = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserRoles", x => x.Id);
                    table.ForeignKey(
                        name: "FK_UserRoles_Roles_RoleId",
                        column: x => x.RoleId,
                        principalTable: "Roles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_UserRoles_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Favorites",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    ProductId = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Favorites", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Favorites_Products_ProductId",
                        column: x => x.ProductId,
                        principalTable: "Products",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Favorites_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ProductImages",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ImageUrl = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    ProductId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ProductImages", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ProductImages_Products_ProductId",
                        column: x => x.ProductId,
                        principalTable: "Products",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "CartItems",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CartId = table.Column<int>(type: "int", nullable: false),
                    ProductId = table.Column<int>(type: "int", nullable: true),
                    ProductName = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Price = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    Quantity = table.Column<int>(type: "int", nullable: false),
                    CardMessage = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SpecialInstructions = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ImageUrl = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    CustomBouquetId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CartItems", x => x.Id);
                    table.ForeignKey(
                        name: "FK_CartItems_Carts_CartId",
                        column: x => x.CartId,
                        principalTable: "Carts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_CartItems_CustomBouquets_CustomBouquetId",
                        column: x => x.CustomBouquetId,
                        principalTable: "CustomBouquets",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_CartItems_Products_ProductId",
                        column: x => x.ProductId,
                        principalTable: "Products",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "CustomBouquetItems",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CustomBouquetId = table.Column<int>(type: "int", nullable: false),
                    ProductId = table.Column<int>(type: "int", nullable: false),
                    Quantity = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CustomBouquetItems", x => x.Id);
                    table.ForeignKey(
                        name: "FK_CustomBouquetItems_CustomBouquets_CustomBouquetId",
                        column: x => x.CustomBouquetId,
                        principalTable: "CustomBouquets",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_CustomBouquetItems_Products_ProductId",
                        column: x => x.ProductId,
                        principalTable: "Products",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "OrderDetails",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    OrderId = table.Column<int>(type: "int", nullable: false),
                    ProductId = table.Column<int>(type: "int", nullable: true),
                    Quantity = table.Column<int>(type: "int", nullable: false),
                    PriceAtPurchase = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    CardMessage = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SpecialInstructions = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    CustomBouquetId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_OrderDetails", x => x.Id);
                    table.ForeignKey(
                        name: "FK_OrderDetails_CustomBouquets_CustomBouquetId",
                        column: x => x.CustomBouquetId,
                        principalTable: "CustomBouquets",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_OrderDetails_Orders_OrderId",
                        column: x => x.OrderId,
                        principalTable: "Orders",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_OrderDetails_Products_ProductId",
                        column: x => x.ProductId,
                        principalTable: "Products",
                        principalColumn: "Id");
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

            migrationBuilder.CreateTable(
                name: "DecorationSelections",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    DecorationRequestId = table.Column<int>(type: "int", nullable: false),
                    DecorationSuggestionId = table.Column<int>(type: "int", nullable: false),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    Comments = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Status = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DecorationSelections", x => x.Id);
                    table.ForeignKey(
                        name: "FK_DecorationSelections_DecorationRequests_DecorationRequestId",
                        column: x => x.DecorationRequestId,
                        principalTable: "DecorationRequests",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_DecorationSelections_DecorationSuggestions_DecorationSuggestionId",
                        column: x => x.DecorationSuggestionId,
                        principalTable: "DecorationSuggestions",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_DecorationSelections_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.InsertData(
                table: "BlogPosts",
                columns: new[] { "Id", "Content", "CreatedAt", "Title" },
                values: new object[,]
                {
                    { 1, "Spring is the perfect time to bring fresh flowers into your home. Here are ten beautiful arrangements that celebrate the season's blooms...", new DateTime(2025, 3, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), "10 Beautiful Spring Flower Arrangements" },
                    { 2, "Houseplants add life and beauty to any space, but they require proper care. Learn essential tips for watering, sunlight, and seasonal maintenance...", new DateTime(2025, 4, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), "How to Care for Your Houseplants" },
                    { 3, "Your wedding bouquet is a crucial part of your special day. Explore different styles, seasonal options, and how to match your bouquet to your wedding theme...", new DateTime(2025, 5, 5, 0, 0, 0, 0, DateTimeKind.Unspecified), "Creating the Perfect Wedding Bouquet" },
                    { 4, "When temperatures rise, you need blooms that can withstand the heat. Discover gorgeous flowers that will keep your garden vibrant all summer long...", new DateTime(2025, 6, 20, 0, 0, 0, 0, DateTimeKind.Unspecified), "Flowers That Thrive in Summer Heat" },
                    { 5, "For centuries, flowers have carried special meanings. Learn the hidden symbolism behind popular blooms to make your next gift more meaningful...", new DateTime(2025, 7, 12, 0, 0, 0, 0, DateTimeKind.Unspecified), "The Language of Flowers: What Each Bloom Symbolizes" }
                });

            migrationBuilder.InsertData(
                table: "Carts",
                columns: new[] { "Id", "CreatedAt", "UserId" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 7, 30, 0, 0, 0, 0, DateTimeKind.Unspecified), 1 },
                    { 2, new DateTime(2025, 7, 31, 0, 0, 0, 0, DateTimeKind.Unspecified), 2 },
                    { 3, new DateTime(2025, 8, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 3 }
                });

            migrationBuilder.InsertData(
                table: "Categories",
                columns: new[] { "Id", "CategoryImageUrl", "Description", "Name" },
                values: new object[,]
                {
                    { 1, "https://florablobstorage.blob.core.windows.net/profile-images/pinklillies.jpg", "Beautifully arranged mixed flowers for all occasions.", "Bouquets" },
                    { 2, "https://florablobstorage.blob.core.windows.net/profile-images/homeplants.png", "Green gifts that grow with love.", "Plants" },
                    { 3, "https://florablobstorage.blob.core.windows.net/profile-images/domesss.png", "Flowers combined with chocolates, perfumes and more.", "Domes" },
                    { 4, "https://florablobstorage.blob.core.windows.net/profile-images/flowes.png", "For custom bouquets", "Flower" },
                    { 5, "https://florablobstorage.blob.core.windows.net/profile-images/box1.jpg", "Flower arrangements in beautiful boxes", "Box" },
                    { 6, "https://florablobstorage.blob.core.windows.net/profile-images/giftset.png", "Flowers combined with chocolates, perfumes and more.", "Gift Sets" },
                    { 7, "https://florablobstorage.blob.core.windows.net/profile-images/weeding.jpg", "Elegant wedding bouquets for brides", "Bridal Bouquets" }
                });

            migrationBuilder.InsertData(
                table: "DonationCampaigns",
                columns: new[] { "Id", "Description", "EndDate", "ImageUrl", "Title" },
                values: new object[,]
                {
                    { 1, "Help us build a community garden in downtown Sarajevo where children can learn about plants and sustainable gardening.", new DateTime(2025, 12, 31, 0, 0, 0, 0, DateTimeKind.Unspecified), "https://florablobstorage.blob.core.windows.net/profile-images/pinktulips.jpg", "Community Garden Project" },
                    { 2, "Donate to help us deliver fresh flowers to patients in local hospitals, bringing joy and color to those who need it most.", new DateTime(2025, 10, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), "https://florablobstorage.blob.core.windows.net/profile-images/pinktulips.jpg", "Flowers for Hospitals" },
                    { 3, "Support our initiative to teach gardening in schools, providing students with hands-on experience growing plants and flowers.", new DateTime(2026, 5, 30, 0, 0, 0, 0, DateTimeKind.Unspecified), "https://florablobstorage.blob.core.windows.net/profile-images/pinktulips.jpg", "School Gardening Education" }
                });

            migrationBuilder.InsertData(
                table: "Occasions",
                columns: new[] { "OccasionId", "Name" },
                values: new object[,]
                {
                    { 1, "Birthday" },
                    { 2, "Newborns" },
                    { 3, "Graduation" }
                });

            migrationBuilder.InsertData(
                table: "Roles",
                columns: new[] { "Id", "CreatedAt", "Description", "IsActive", "Name" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 8, 5, 0, 0, 0, 0, DateTimeKind.Unspecified), "Administrator role", true, "Admin" },
                    { 2, new DateTime(2025, 8, 5, 0, 0, 0, 0, DateTimeKind.Unspecified), "Standard user role", true, "User" }
                });

            migrationBuilder.InsertData(
                table: "ShippingAddresses",
                columns: new[] { "Id", "City", "FirstName", "HouseNumber", "LastName", "OrderNote", "PostalCode", "Street" },
                values: new object[,]
                {
                    { 1, "Sarajevo", "Maja", "10", "Hodžić", "Please call before delivery", "71000", "Zmaja od Bosne" },
                    { 2, "Mostar", "Amina", "15", "Delić", "Leave at reception", "88000", "Kralja Tvrtka" },
                    { 3, "Tuzla", "Emina", "8", "Jahić", null, "75000", "Pozorišna" },
                    { 4, "Zenica", "Medin", "22", "Mujkić", "Apartment 3, 2nd floor", "72000", "Maršala Tita" }
                });

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "Id", "CreatedAt", "Email", "FirstName", "IsActive", "LastLoginAt", "LastName", "PasswordHash", "PasswordSalt", "PhoneNumber", "ProfileImageUrl", "Username" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 8, 7, 16, 8, 16, 842, DateTimeKind.Utc).AddTicks(4108), "admin@flora.com", "Admin", true, null, "Admin", "qDwRm1Je9uV+OOVzUkx39yVc6kwX7kHXghsphGzASt8=", "XN5np4S0VzWNtZLrR/NTQg==", null, null, "admin" },
                    { 2, new DateTime(2025, 8, 7, 16, 8, 16, 842, DateTimeKind.Utc).AddTicks(4114), "user@flora.com", "User", true, null, "User", "gX/yzzWNl+5dUWP7r+SoKS/4oWbaLISB07DQtz6PfMU=", "RqPOpvr8F7P+yM9Giv+K0w==", null, null, "user" },
                    { 3, new DateTime(2025, 8, 7, 16, 8, 16, 842, DateTimeKind.Utc).AddTicks(4116), "medina@flora.com", "Medina", true, null, "Krhan", "uzCHhrGT3SlTTIK9h8fFYUfs7Nxzg59xwhqW/z7Dz6Q=", "YXKd1kb3lhk3uTvfEo5L7Q==", null, null, "medina" }
                });

            migrationBuilder.InsertData(
                table: "BlogComments",
                columns: new[] { "Id", "AuthorName", "BlogPostId", "Content", "CreatedAt", "UserId" },
                values: new object[,]
                {
                    { 1, "", 1, "These spring arrangements are gorgeous! I especially love the tulip and daffodil combination.", new DateTime(2025, 3, 16, 0, 0, 0, 0, DateTimeKind.Unspecified), 2 },
                    { 2, "", 2, "Thanks for the houseplant tips! I've been struggling with my fiddle leaf fig and this was really helpful.", new DateTime(2025, 4, 11, 0, 0, 0, 0, DateTimeKind.Unspecified), 3 },
                    { 3, "", 3, "I used your advice for my wedding last month and my bouquet was perfect! Thank you!", new DateTime(2025, 5, 6, 0, 0, 0, 0, DateTimeKind.Unspecified), 3 },
                    { 4, "", 4, "Great article! I'll be sharing these summer flower tips with our customers.", new DateTime(2025, 6, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 2 },
                    { 5, "", 5, "I never knew roses had such complex meanings. This will help me choose better gifts!", new DateTime(2025, 7, 13, 0, 0, 0, 0, DateTimeKind.Unspecified), 2 }
                });

            migrationBuilder.InsertData(
                table: "BlogImages",
                columns: new[] { "Id", "BlogPostId", "Url" },
                values: new object[,]
                {
                    { 1, 1, "https://florablobstorage.blob.core.windows.net/profile-images/pinklillies.jpg" },
                    { 2, 2, "https://florablobstorage.blob.core.windows.net/profile-images/palm.png" },
                    { 3, 3, "https://florablobstorage.blob.core.windows.net/profile-images/weeding5.jpg" },
                    { 4, 4, "https://florablobstorage.blob.core.windows.net/profile-images/bluetulips.jpg" },
                    { 5, 5, "https://florablobstorage.blob.core.windows.net/profile-images/pinklillies.jpg" }
                });

            migrationBuilder.InsertData(
                table: "CustomBouquets",
                columns: new[] { "Id", "CardMessage", "Color", "SpecialInstructions", "TotalPrice", "UserId" },
                values: new object[,]
                {
                    { 1, "Happy Valentine's Day!", "Red", "Arrange in heart shape if possible", 65.00m, 2 },
                    { 2, "Happy Mother's Day!", "Pink", null, 55.00m, 3 },
                    { 3, "Congratulations on your baby boy!", "Blue", "Include a small teddy bear if available", 80.00m, 3 }
                });

            migrationBuilder.InsertData(
                table: "DecorationRequests",
                columns: new[] { "Id", "Budget", "EventDate", "EventType", "Location", "NumberOfGuests", "NumberOfTables", "SpecialRequests", "ThemeOrColors", "UserId", "VenueType" },
                values: new object[,]
                {
                    { 1, 2000.00m, new DateTime(2025, 9, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), "Wedding", "Sarajevo", 150, 20, "Bride is allergic to lilies, please avoid using them", "White and Gold", 2, "Hotel Ballroom" },
                    { 2, 500.00m, new DateTime(2025, 8, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), "Birthday Party", "Mostar", 50, 8, "Need table centerpieces and entrance decoration", "Blue and Silver", 3, "Restaurant" },
                    { 3, 1500.00m, new DateTime(2025, 11, 20, 0, 0, 0, 0, DateTimeKind.Unspecified), "Corporate Event", "Tuzla", 200, 25, "Need stage decoration and branded floral arrangements", "Company colors: Red and Black", 3, "Conference Hall" }
                });

            migrationBuilder.InsertData(
                table: "Donations",
                columns: new[] { "Id", "Amount", "CampaignId", "Date", "DonorName", "Email", "Purpose", "Status", "TransactionId", "UserId" },
                values: new object[,]
                {
                    { 1, 50.0, 1, new DateTime(2025, 7, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), "Maja", "maja@example.com", "Community Garden Project", "Completed", "PAY-1DX87612GH298734K", 2 },
                    { 2, 25.0, 2, new DateTime(2025, 7, 20, 0, 0, 0, 0, DateTimeKind.Unspecified), "Amina", "amina@example.com", "Flowers for Hospitals", "Completed", "PAY-9HG76354KJ298345L", 3 },
                    { 3, 100.0, 3, new DateTime(2025, 7, 25, 0, 0, 0, 0, DateTimeKind.Unspecified), "Emina", "emina@example.com", "School Gardening Education", "Completed", "PAY-7JH98345KL456789M", 3 },
                    { 4, 75.0, 1, new DateTime(2025, 7, 28, 0, 0, 0, 0, DateTimeKind.Unspecified), "Medin", "medin@example.com", "Community Garden Project", "Completed", "PAY-2KL87345JH765432N", 2 }
                });

            migrationBuilder.InsertData(
                table: "Orders",
                columns: new[] { "Id", "OrderDate", "ShippingAddressId", "Status", "TotalAmount", "UserId" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 7, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 1, "Completed", 135.00m, 2 },
                    { 2, new DateTime(2025, 7, 5, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, "Delivered", 80.00m, 3 },
                    { 3, new DateTime(2025, 7, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), 3, "Processed", 50.00m, 3 },
                    { 4, new DateTime(2025, 7, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), 4, "PaymentInitiated", 100.00m, 2 }
                });

            migrationBuilder.InsertData(
                table: "Products",
                columns: new[] { "Id", "Active", "CategoryId", "Description", "IsAvailable", "IsFeatured", "IsNew", "Name", "OccasionId", "Price" },
                values: new object[,]
                {
                    { 1, true, 5, "Flowers beautifully arranged in a box for newborn baby", true, false, false, "Welcome Baby Girl", 2, 60.00m },
                    { 2, true, 5, "Flowers beautifully arranged in a box for newborn baby", true, false, false, "Welcome Baby Boy", 2, 60.00m },
                    { 3, true, 1, "Luxury rosegold bouquet with 101 rose in mixed colors for our birthday queens", true, true, true, "Happy Birthday Queen", 1, 150.00m },
                    { 4, true, 1, "A stunning bouquet of 20 exquisite blue tulips, hand-picked at peak bloom for their rich sapphire hue. Accented with delicate white waxflowers and soft silver eucalyptus leaves, this arrangement brings a cool, serene elegance to any space, perfect for those who appreciate rare beauty and timeless style.", true, false, false, "Blue Tulip Elegance", 2, 80.00m },
                    { 5, true, 5, "An opulent arrangement featuring over 50 hand-selected blooms, including velvety red roses, fragrant gardenias, delicate lilies, and soft spray carnations.", true, true, true, "Eternal Blossom Box", 1, 180.00m },
                    { 6, true, 5, "A luxurious gift box featuring a lush blue hydrangea centerpiece surrounded by delicate white baby's breath and sprigs of fresh greenery.", true, false, true, "Serenity Blue Box", 2, 100.00m },
                    { 7, true, 5, "A charming gift box filled with a stunning mix of soft pink roses, delicate peonies, and lush ranunculus blooms.", true, false, true, "Blush Elegance Box", 1, 90.00m },
                    { 8, true, 5, "Elegant box filled with pristine white roses symbolizing purity and grace, complemented by delicate white lilies and soft greenery", true, false, false, "Pure Serenity Box", null, 80.00m },
                    { 9, true, 5, "Elegant box with 20 red roses", true, false, true, "Flower Box Deluxe", null, 70.00m },
                    { 10, true, 5, "A romantic heart-shaped box overflowing with lush, velvety pink roses, symbolizing love and admiration.", true, true, true, "Blush Heart Box", 1, 120.00m },
                    { 11, true, 2, "A resilient beauty with minimal care needs, this spiky companion adds a touch of desert magic and modern style to any space.", true, false, false, "Cactus", null, 18.00m },
                    { 12, true, 2, "With its tall, graceful stalks and lush, arching green leaves, the Corn Plant brings a tropical vibe and elegant greenery to any interior. ", true, false, false, "Cornplant", null, 25.00m },
                    { 13, true, 1, "Gracefully arranged white dahlias nestled in a serene blue bouquet, creating a perfect harmony of purity and calm. ", true, false, true, "Elegant White Dahlias Bouquet", 2, 60.00m },
                    { 14, true, 3, "A warm mix of golden roses and amber-colored wildflowers under a glass dome", true, true, false, "Golden Hour Dome", null, 100.00m },
                    { 15, true, 3, "A magical blend of fresh roses, lavender sprigs, and eucalyptus leaves artfully enclosed in a crystal-clear glass dome.", true, false, false, "The Enchanted Garden Dome", null, 70.00m },
                    { 16, true, 3, "A single, stunning blue rose preserved under a crystal-clear glass dome. Symbolizing mystery and rarity.", true, false, true, "Midnight Bloom Dome", null, 40.00m },
                    { 17, true, 3, "Elegant dome perfect for the holiday season.", true, false, true, "Winter Wonderland Dome", null, 70.00m },
                    { 18, true, 3, "This dome bouquet brings joy and festive charm to any birthday celebration. Perfect as a memorable gift that lasts.", true, false, true, "Birthday Bliss Dome", 1, 60.00m },
                    { 19, true, 1, "A stunning medley of roses, gerberas, and seasonal blooms, expertly arranged to create a harmonious explosion of color and fragrance.", true, false, false, "Garden Symphony Bouquet", null, 60.00m },
                    { 20, true, 1, "An exuberant gathering of seasonal blooms: daffodils, hyacinths, ranunculus, and freesias,", true, false, true, "Spring Awakening Mix", null, 40.00m },
                    { 21, true, 1, "A bouquet of fresh pink flowers.", true, true, true, "Pink Bloosom Bouquet", 1, 50.00m },
                    { 22, true, 1, "A cheerful arrangement featuring soft pink gerberas and fresh white daisies", true, false, false, "Pink Delight Bouquet", null, 35.00m },
                    { 23, true, 1, " With 30 red roses, this bouquet captures the pride and happiness of a milestone reached.", true, false, false, "Achievement Celebration Bouquet", 3, 135.00m },
                    { 24, true, 1, "A colorful medley of roses, tulips, and daisies in bold and bright hues, designed to inspire and celebrate this momentous occasion.", true, false, false, "Graduation Glory Mix", 3, 75.00m },
                    { 25, true, 1, "A colorful medley of roses, tulips, and daisies in bold and bright hues, designed to inspire and celebrate this momentous occasion.", true, false, false, "Graduation Celebration Mix", 3, 75.00m },
                    { 26, true, 5, "A cheerful arrangement featuring soft pink roses, designed to inspire and celebrate this moments.", true, false, false, "Bright Future Blossoms", 3, 95.00m },
                    { 27, true, 1, "Delicate blue hydrangea blooms evoke the refreshing coolness of ocean waves.", true, false, false, "Ocean Breeze Hydrangea", null, 45.00m },
                    { 28, true, 2, "Bring a touch of the tropics into your home with this elegant palm.", true, false, false, "Palm", null, 25.00m },
                    { 29, true, 2, "Known for its glossy leaves and delicate white blooms, the Peace Lily purifies your air while adding a serene and peaceful vibe to your living space.", true, false, false, "Peace Lilly", null, 20.00m },
                    { 30, true, 2, "With lush, heart-shaped leaves, the Philodendron adds a vibrant splash of green and effortless style.", true, false, false, "Philodendron", null, 20.00m },
                    { 31, true, 1, "Bright and cheerful tulips bouquet", true, false, false, "Pink Lillies Bouquet", null, 40.00m },
                    { 32, true, 1, "Bright and cheerful tulips bouquet.", true, false, false, "Pink Tulips Bouquet", null, 35.00m },
                    { 33, true, 1, "Bright and cheerful tulips bouquet.", true, false, false, "Purple Tulips Bouquet", null, 35.00m },
                    { 34, true, 1, "Bright and cheerful red roses bouquet.", true, false, false, "Red Roses Bouquet", null, 5.00m },
                    { 35, true, 2, "A hardy and architectural beauty, the Snake Plant features tall, upright leaves with striking variegation.", true, false, false, "Snake Plant", null, 25.00m },
                    { 36, true, 2, "With its arching, striped leaves and cascading baby “spiders,” this lively plant brings dynamic energy and a fresh vibe to any room..", true, false, false, "Spider Plant", null, 35.00m },
                    { 37, true, 2, "Compact and resilient, this succulent boasts fleshy leaves in vibrant shades", true, false, false, "Suculents ", null, 35.00m },
                    { 38, true, 7, "A timeless bouquet featuring pristine white roses and delicate peonies, symbolizing everlasting love and grace.", true, true, false, "Eternal Elegance", null, 55.00m },
                    { 39, true, 7, "An opulent arrangement of blush roses, cream dahlias, and eucalyptus — a perfect statement of lavish celebration.", true, false, false, "Blushing Bride", null, 65.00m },
                    { 40, true, 7, "Elegant white calla lilies, known for their purity and refined beauty.", true, false, false, "Pure Grace", null, 45.00m },
                    { 41, true, 7, "A refined bouquet of long-stemmed calla lilies, gently complemented by red roses", true, false, false, "Winter bride", null, 55.00m },
                    { 42, true, 7, "A fresh and airy bouquet with dew-kissed ranunculus and white lisianthus,", true, false, false, "Dreamy Dew", null, 30.00m },
                    { 43, true, 6, "Capture the warmth of golden moments with this curated box of florals, fine confections, and timeless keepsakes.", true, false, false, "Golden Hour", 1, 145.00m },
                    { 44, true, 6, "Overflowing with elegant flowers and premium goodies, this box delivers an unforgettable sensory experience.", true, false, false, "Pure Indulgence", 1, 135.00m },
                    { 45, true, 6, "A romantic ensemble of roses, chocolate truffles, and a hint of fragrance – a heartfelt gift for someone special.", true, false, false, "Amour Box ", 1, 135.00m },
                    { 46, true, 6, "A calming mix of greenery, soft blooms, and wellness items – perfect for relaxation and self-care.", true, true, false, "Serenity Set ", 1, 150.00m },
                    { 47, true, 6, "Mystical and enchanting, this box blends deep-toned florals with luxurious gifts for a bold expression of love.", true, false, false, "Midnight Bloom", 1, 150.00m },
                    { 48, true, 4, ".", true, false, false, "Gerber", null, 4.00m },
                    { 49, true, 4, ".", true, false, false, "Baby's Breath", null, 2.00m },
                    { 50, true, 4, ".", true, false, false, "Lilly", null, 3.00m },
                    { 51, true, 4, ".", true, false, false, "Margarita", null, 5.00m },
                    { 52, true, 4, ".", true, false, false, "Tulip", null, 5.00m },
                    { 53, true, 4, ".", true, false, false, "Rose", null, 7.00m },
                    { 54, true, 4, ".", true, false, false, "Daisy", null, 4.00m },
                    { 55, true, 4, ".", true, false, false, "Hydrangea", null, 8.00m },
                    { 56, true, 4, ".", true, false, false, "Calla Lilly", null, 6.00m }
                });

            migrationBuilder.InsertData(
                table: "UserRoles",
                columns: new[] { "Id", "DateAssigned", "RoleId", "UserId" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 8, 5, 0, 0, 0, 0, DateTimeKind.Unspecified), 1, 1 },
                    { 2, new DateTime(2025, 8, 5, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, 2 },
                    { 3, new DateTime(2025, 8, 5, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, 3 }
                });

            migrationBuilder.InsertData(
                table: "CartItems",
                columns: new[] { "Id", "CardMessage", "CartId", "CustomBouquetId", "ImageUrl", "Price", "ProductId", "ProductName", "Quantity", "SpecialInstructions" },
                values: new object[,]
                {
                    { 1, "Happy Birthday!", 1, null, "https://florablobstorage.blob.core.windows.net/profile-images/box3.jpg", 180.00m, 5, "Eternal Blossom Box", 1, null },
                    { 2, "Get well soon!", 2, null, "https://florablobstorage.blob.core.windows.net/profile-images/box3.jpg", 50.00m, 21, "Pink Bloosom Bouquet", 1, null },
                    { 3, null, 2, null, "https://florablobstorage.blob.core.windows.net/profile-images/box3.jpg", 20.00m, 29, "Peace Lilly", 2, null }
                });

            migrationBuilder.InsertData(
                table: "CustomBouquetItems",
                columns: new[] { "Id", "CustomBouquetId", "ProductId", "Quantity" },
                values: new object[,]
                {
                    { 1, 1, 53, 7 },
                    { 2, 1, 49, 3 },
                    { 3, 2, 48, 5 },
                    { 4, 2, 50, 3 },
                    { 5, 2, 49, 2 },
                    { 6, 3, 55, 2 },
                    { 7, 3, 54, 6 },
                    { 8, 3, 49, 4 }
                });

            migrationBuilder.InsertData(
                table: "DecorationSuggestions",
                columns: new[] { "Id", "DecorationRequestId", "Description", "ImageUrl" },
                values: new object[,]
                {
                    { 1, 1, "Elegant table centerpieces with white roses and gold accents", "https://florablobstorage.blob.core.windows.net/profile-images/bluetulips.jpg" },
                    { 2, 1, "Entrance archway decorated with white orchids and gold drapery", "https://florablobstorage.blob.core.windows.net/profile-images/box1.jpg" },
                    { 3, 2, "Blue hydrangea centerpieces with silver accents", "https://florablobstorage.blob.core.windows.net/profile-images/box2.jpg" },
                    { 4, 3, "Modern arrangements with red roses and black accents, incorporating company logo", "https://florablobstorage.blob.core.windows.net/profile-images/box3.jpg" }
                });

            migrationBuilder.InsertData(
                table: "Favorites",
                columns: new[] { "Id", "CreatedAt", "ProductId", "UserId" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 6, 15, 0, 0, 0, 0, DateTimeKind.Unspecified), 3, 2 },
                    { 2, new DateTime(2025, 6, 16, 0, 0, 0, 0, DateTimeKind.Unspecified), 10, 2 },
                    { 3, new DateTime(2025, 6, 20, 0, 0, 0, 0, DateTimeKind.Unspecified), 21, 3 },
                    { 4, new DateTime(2025, 7, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 5, 3 },
                    { 5, new DateTime(2025, 7, 5, 0, 0, 0, 0, DateTimeKind.Unspecified), 14, 3 },
                    { 6, new DateTime(2025, 7, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), 38, 3 }
                });

            migrationBuilder.InsertData(
                table: "OrderDetails",
                columns: new[] { "Id", "CardMessage", "CustomBouquetId", "OrderId", "PriceAtPurchase", "ProductId", "Quantity", "SpecialInstructions" },
                values: new object[,]
                {
                    { 1, "Happy Birthday Mom! Love, Maja", null, 1, 150.00m, 3, 1, "Please deliver before noon" },
                    { 2, "Congratulations on your new home!", null, 2, 80.00m, 4, 1, null },
                    { 3, "Get well soon!", null, 3, 35.00m, 22, 1, null },
                    { 4, null, null, 3, 18.00m, 11, 1, null },
                    { 5, "Happy Anniversary!", null, 4, 100.00m, 14, 1, "Include a ribbon" }
                });

            migrationBuilder.InsertData(
                table: "ProductImages",
                columns: new[] { "Id", "ImageUrl", "ProductId" },
                values: new object[,]
                {
                    { 1, "https://florablobstorage.blob.core.windows.net/profile-images/birth.jpg", 1 },
                    { 2, "https://florablobstorage.blob.core.windows.net/profile-images/birth2.jpg", 2 },
                    { 3, "https://florablobstorage.blob.core.windows.net/profile-images/birthday.jpg", 3 },
                    { 4, "https://florablobstorage.blob.core.windows.net/profile-images/bluetulips.jpg", 4 },
                    { 5, "https://florablobstorage.blob.core.windows.net/profile-images/chocolateflowerdome2.jpg", 5 },
                    { 6, "https://florablobstorage.blob.core.windows.net/profile-images/box2.jpg", 6 },
                    { 7, "https://florablobstorage.blob.core.windows.net/profile-images/box3.jpg", 7 },
                    { 8, "https://florablobstorage.blob.core.windows.net/profile-images/box4.jpg", 8 },
                    { 9, "https://florablobstorage.blob.core.windows.net/profile-images/box5.jpg", 9 },
                    { 10, "https://florablobstorage.blob.core.windows.net/profile-images/box7.jpg", 10 },
                    { 11, "https://florablobstorage.blob.core.windows.net/profile-images/cactus.png", 11 },
                    { 12, "https://florablobstorage.blob.core.windows.net/profile-images/cornplant.png", 12 },
                    { 13, "https://florablobstorage.blob.core.windows.net/profile-images/dalias.jpg", 13 },
                    { 14, "https://florablobstorage.blob.core.windows.net/profile-images/flowerdome2.jpg", 14 },
                    { 15, "https://florablobstorage.blob.core.windows.net/profile-images/flowerdome3.jpg", 15 },
                    { 16, "https://florablobstorage.blob.core.windows.net/profile-images/flowerdome4.jpg", 16 },
                    { 17, "https://florablobstorage.blob.core.windows.net/profile-images/flowerdome6.jpg", 17 },
                    { 18, "https://florablobstorage.blob.core.windows.net/profile-images/flowerdomebirthday.jpg", 18 },
                    { 19, "https://florablobstorage.blob.core.windows.net/profile-images/flowermix1.jpg", 19 },
                    { 20, "https://florablobstorage.blob.core.windows.net/profile-images/flowermix2.jpg", 20 },
                    { 21, "https://florablobstorage.blob.core.windows.net/profile-images/flowermix3.jpg", 21 },
                    { 22, "https://florablobstorage.blob.core.windows.net/profile-images/gerbers.jpg", 22 },
                    { 23, "https://florablobstorage.blob.core.windows.net/profile-images/graduation.jpg", 23 },
                    { 24, "https://florablobstorage.blob.core.windows.net/profile-images/graduation2.jpg", 24 },
                    { 25, "https://florablobstorage.blob.core.windows.net/profile-images/graduation3.jpg", 25 },
                    { 26, "https://florablobstorage.blob.core.windows.net/profile-images/graduation6.jpg", 26 },
                    { 27, "https://florablobstorage.blob.core.windows.net/profile-images/hidrogenia.jpg", 22 },
                    { 28, "https://florablobstorage.blob.core.windows.net/profile-images/palm.png", 28 },
                    { 29, "https://florablobstorage.blob.core.windows.net/profile-images/peacelilly.png", 29 },
                    { 30, "https://florablobstorage.blob.core.windows.net/profile-images/philodendron.png", 30 },
                    { 31, "https://florablobstorage.blob.core.windows.net/profile-images/pinklillies.jpg", 31 },
                    { 32, "https://florablobstorage.blob.core.windows.net/profile-images/pinktulips.jpg", 22 },
                    { 33, "https://florablobstorage.blob.core.windows.net/profile-images/purpletulips.jpg", 33 },
                    { 34, "https://florablobstorage.blob.core.windows.net/profile-images/red%20roses.jpg", 34 },
                    { 35, "https://florablobstorage.blob.core.windows.net/profile-images/snakeplant.png", 35 },
                    { 36, "https://florablobstorage.blob.core.windows.net/profile-images/spiderplant.png", 36 },
                    { 37, "https://florablobstorage.blob.core.windows.net/profile-images/suculents.png", 37 },
                    { 38, "https://florablobstorage.blob.core.windows.net/profile-images/weeding.jpg", 38 },
                    { 39, "https://florablobstorage.blob.core.windows.net/profile-images/weeding2.jpg", 39 },
                    { 40, "https://florablobstorage.blob.core.windows.net/profile-images/weeding3.jpg", 40 },
                    { 41, "https://florablobstorage.blob.core.windows.net/profile-images/weeding4.jpg", 41 },
                    { 42, "https://florablobstorage.blob.core.windows.net/profile-images/weeding5.jpg", 42 },
                    { 43, "https://florablobstorage.blob.core.windows.net/profile-images/agb1.jpg", 43 },
                    { 44, "https://florablobstorage.blob.core.windows.net/profile-images/agb2.jpg", 44 },
                    { 45, "https://florablobstorage.blob.core.windows.net/profile-images/agb3.jpg", 45 },
                    { 46, "https://florablobstorage.blob.core.windows.net/profile-images/agb4.jpg", 46 },
                    { 47, "https://florablobstorage.blob.core.windows.net/profile-images/agb5.jpg", 47 },
                    { 48, "https://florablobstorage.blob.core.windows.net/profile-images/cb1.jpg", 48 },
                    { 49, "https://florablobstorage.blob.core.windows.net/profile-images/cb2.jpg", 49 },
                    { 50, "https://florablobstorage.blob.core.windows.net/profile-images/cb3.jpg", 50 },
                    { 51, "https://florablobstorage.blob.core.windows.net/profile-images/cb4.jpg", 51 },
                    { 52, "https://florablobstorage.blob.core.windows.net/profile-images/cb5.jpg", 52 },
                    { 53, "https://florablobstorage.blob.core.windows.net/profile-images/cb6.jpg", 53 },
                    { 54, "https://florablobstorage.blob.core.windows.net/profile-images/cb7.jpg", 54 },
                    { 55, "https://florablobstorage.blob.core.windows.net/profile-images/cb8.jpg", 55 },
                    { 56, "https://florablobstorage.blob.core.windows.net/profile-images/cb9.jpg", 56 }
                });

            migrationBuilder.InsertData(
                table: "DecorationSelections",
                columns: new[] { "Id", "Comments", "CreatedAt", "DecorationRequestId", "DecorationSuggestionId", "Status", "UserId" },
                values: new object[,]
                {
                    { 1, "I love this design! Can we add a few more roses to each centerpiece?", new DateTime(2025, 7, 20, 14, 30, 0, 0, DateTimeKind.Unspecified), 1, 1, "Selected", 2 },
                    { 2, "Perfect! Please make sure the blue matches the invitations I sent.", new DateTime(2025, 7, 25, 10, 15, 0, 0, DateTimeKind.Unspecified), 2, 3, "Selected", 3 }
                });

            migrationBuilder.CreateIndex(
                name: "IX_BlogComments_BlogPostId",
                table: "BlogComments",
                column: "BlogPostId");

            migrationBuilder.CreateIndex(
                name: "IX_BlogComments_UserId",
                table: "BlogComments",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_BlogImages_BlogPostId",
                table: "BlogImages",
                column: "BlogPostId");

            migrationBuilder.CreateIndex(
                name: "IX_CartItems_CartId",
                table: "CartItems",
                column: "CartId");

            migrationBuilder.CreateIndex(
                name: "IX_CartItems_CustomBouquetId",
                table: "CartItems",
                column: "CustomBouquetId");

            migrationBuilder.CreateIndex(
                name: "IX_CartItems_ProductId",
                table: "CartItems",
                column: "ProductId");

            migrationBuilder.CreateIndex(
                name: "IX_CustomBouquetItems_CustomBouquetId",
                table: "CustomBouquetItems",
                column: "CustomBouquetId");

            migrationBuilder.CreateIndex(
                name: "IX_CustomBouquetItems_ProductId",
                table: "CustomBouquetItems",
                column: "ProductId");

            migrationBuilder.CreateIndex(
                name: "IX_CustomBouquets_UserId",
                table: "CustomBouquets",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_DecorationRequests_UserId",
                table: "DecorationRequests",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_DecorationSelections_DecorationRequestId",
                table: "DecorationSelections",
                column: "DecorationRequestId");

            migrationBuilder.CreateIndex(
                name: "IX_DecorationSelections_DecorationSuggestionId",
                table: "DecorationSelections",
                column: "DecorationSuggestionId");

            migrationBuilder.CreateIndex(
                name: "IX_DecorationSelections_UserId",
                table: "DecorationSelections",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_DecorationSuggestions_DecorationRequestId",
                table: "DecorationSuggestions",
                column: "DecorationRequestId");

            migrationBuilder.CreateIndex(
                name: "IX_Donations_CampaignId",
                table: "Donations",
                column: "CampaignId");

            migrationBuilder.CreateIndex(
                name: "IX_Donations_UserId",
                table: "Donations",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Favorites_ProductId",
                table: "Favorites",
                column: "ProductId");

            migrationBuilder.CreateIndex(
                name: "IX_Favorites_UserId",
                table: "Favorites",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_OrderDetails_CustomBouquetId",
                table: "OrderDetails",
                column: "CustomBouquetId");

            migrationBuilder.CreateIndex(
                name: "IX_OrderDetails_OrderId",
                table: "OrderDetails",
                column: "OrderId");

            migrationBuilder.CreateIndex(
                name: "IX_OrderDetails_ProductId",
                table: "OrderDetails",
                column: "ProductId");

            migrationBuilder.CreateIndex(
                name: "IX_Orders_ShippingAddressId",
                table: "Orders",
                column: "ShippingAddressId");

            migrationBuilder.CreateIndex(
                name: "IX_ProductImages_ProductId",
                table: "ProductImages",
                column: "ProductId");

            migrationBuilder.CreateIndex(
                name: "IX_Products_CategoryId",
                table: "Products",
                column: "CategoryId");

            migrationBuilder.CreateIndex(
                name: "IX_Products_OccasionId",
                table: "Products",
                column: "OccasionId");

            migrationBuilder.CreateIndex(
                name: "IX_Roles_Name",
                table: "Roles",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_UserRoles_RoleId",
                table: "UserRoles",
                column: "RoleId");

            migrationBuilder.CreateIndex(
                name: "IX_UserRoles_UserId_RoleId",
                table: "UserRoles",
                columns: new[] { "UserId", "RoleId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Users_Email",
                table: "Users",
                column: "Email",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Users_Username",
                table: "Users",
                column: "Username",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "BlogComments");

            migrationBuilder.DropTable(
                name: "BlogImages");

            migrationBuilder.DropTable(
                name: "CartItems");

            migrationBuilder.DropTable(
                name: "CustomBouquetItems");

            migrationBuilder.DropTable(
                name: "DecorationSelections");

            migrationBuilder.DropTable(
                name: "Donations");

            migrationBuilder.DropTable(
                name: "Favorites");

            migrationBuilder.DropTable(
                name: "OrderDetails");

            migrationBuilder.DropTable(
                name: "ProductImages");

            migrationBuilder.DropTable(
                name: "UserRoles");

            migrationBuilder.DropTable(
                name: "BlogPosts");

            migrationBuilder.DropTable(
                name: "Carts");

            migrationBuilder.DropTable(
                name: "DecorationSuggestions");

            migrationBuilder.DropTable(
                name: "DonationCampaigns");

            migrationBuilder.DropTable(
                name: "CustomBouquets");

            migrationBuilder.DropTable(
                name: "Orders");

            migrationBuilder.DropTable(
                name: "Products");

            migrationBuilder.DropTable(
                name: "Roles");

            migrationBuilder.DropTable(
                name: "DecorationRequests");

            migrationBuilder.DropTable(
                name: "ShippingAddresses");

            migrationBuilder.DropTable(
                name: "Categories");

            migrationBuilder.DropTable(
                name: "Occasions");

            migrationBuilder.DropTable(
                name: "Users");
        }
    }
}

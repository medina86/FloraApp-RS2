using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Flora.Services.Database.Seeders
{
    public static class OrderDetailSeeder
    {
        public static void SeedData(this EntityTypeBuilder<OrderDetail> entity)
        {
            entity.HasData(
                new OrderDetail
                {
                    Id = 1,
                    OrderId = 1,
                    ProductId = 3,
                    Quantity = 1,
                    PriceAtPurchase = 150.00m,
                    CardMessage = "Happy Birthday Mom! Love, Maja",
                    SpecialInstructions = "Please deliver before noon",
                    CustomBouquetId = null
                },
                new OrderDetail
                {
                    Id = 2,
                    OrderId = 2,
                    ProductId = 4,
                    Quantity = 1,
                    PriceAtPurchase = 80.00m,
                    CardMessage = "Congratulations on your new home!",
                    SpecialInstructions = null,
                    CustomBouquetId = null
                },
                new OrderDetail
                {
                    Id = 3,
                    OrderId = 3,
                    ProductId = 22,
                    Quantity = 1,
                    PriceAtPurchase = 35.00m,
                    CardMessage = "Get well soon!",
                    SpecialInstructions = null,
                    CustomBouquetId = null
                },
                new OrderDetail
                {
                    Id = 4,
                    OrderId = 3,
                    ProductId = 11,
                    Quantity = 1,
                    PriceAtPurchase = 18.00m,
                    CardMessage = null,
                    SpecialInstructions = null,
                    CustomBouquetId = null
                },
                new OrderDetail
                {
                    Id = 5,
                    OrderId = 4,
                    ProductId = 14,
                    Quantity = 1,
                    PriceAtPurchase = 100.00m,
                    CardMessage = "Happy Anniversary!",
                    SpecialInstructions = "Include a ribbon",
                    CustomBouquetId = null
                }
            );
        }
    }
}

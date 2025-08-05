using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Flora.Services.Database.Seeders
{
    public static class CartItemSeeder
    {
        public static void SeedData(this EntityTypeBuilder<CartItem> entity)
        {
            entity.HasData(
                new CartItem
                {
                    Id = 1,
                    CartId = 1,
                    ProductId = 5,
                    ProductName = "Eternal Blossom Box",
                    Price = 180.00m,
                    Quantity = 1,
                    CardMessage = "Happy Birthday!",
                    SpecialInstructions = null,
                    ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/box3.jpg",
                    CustomBouquetId = null
                },
                
                new CartItem
                {
                    Id = 2,
                    CartId = 2,
                    ProductId = 21,
                    ProductName = "Pink Bloosom Bouquet",
                    Price = 50.00m,
                    Quantity = 1,
                    CardMessage = "Get well soon!",
                    SpecialInstructions = null,
                    ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/box3.jpg",
                    CustomBouquetId = null
                },
                new CartItem
                {
                    Id = 3,
                    CartId = 2,
                    ProductId = 29,
                    ProductName = "Peace Lilly",
                    Price = 20.00m,
                    Quantity = 2,
                    CardMessage = null,
                    SpecialInstructions = null,
                    ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/box3.jpg",
                    CustomBouquetId = null
                }
                
                
            );
        }
    }
}

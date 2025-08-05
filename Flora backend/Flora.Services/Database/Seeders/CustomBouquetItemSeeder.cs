using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Flora.Services.Database.Seeders
{
    public static class CustomBouquetItemSeeder
    {
        public static void SeedData(this EntityTypeBuilder<CustomBouquetItem> entity)
        {
            entity.HasData(
                new CustomBouquetItem
                {
                    Id = 1,
                    CustomBouquetId = 1,
                    ProductId = 53, // Rose
                    Quantity = 7
                },
                new CustomBouquetItem
                {
                    Id = 2,
                    CustomBouquetId = 1,
                    ProductId = 49, // Baby's Breath
                    Quantity = 3
                },
                
                new CustomBouquetItem
                {
                    Id = 3,
                    CustomBouquetId = 2,
                    ProductId = 48, // Gerber
                    Quantity = 5
                },
                new CustomBouquetItem
                {
                    Id = 4,
                    CustomBouquetId = 2,
                    ProductId = 50, // Lilly
                    Quantity = 3
                },
                new CustomBouquetItem
                {
                    Id = 5,
                    CustomBouquetId = 2,
                    ProductId = 49, // Baby's Breath
                    Quantity = 2
                },
                
                new CustomBouquetItem
                {
                    Id = 6,
                    CustomBouquetId = 3,
                    ProductId = 55, // Hydrangea (using as blue flower)
                    Quantity = 2
                },
                new CustomBouquetItem
                {
                    Id = 7,
                    CustomBouquetId = 3,
                    ProductId = 54, // Daisy 
                    Quantity = 6
                },
                new CustomBouquetItem
                {
                    Id = 8,
                    CustomBouquetId = 3,
                    ProductId = 49, // Baby's Breath
                    Quantity = 4
                }
            );
        }
    }
}

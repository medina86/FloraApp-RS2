using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Flora.Services.Database.Seeders
{
    public static class CustomBouquetSeeder
    {
        public static void SeedData(this EntityTypeBuilder<CustomBouquet> entity)
        {
            entity.HasData(
                new CustomBouquet
                {
                    Id = 1,
                    Color = "Red",
                    CardMessage = "Happy Valentine's Day!",
                    SpecialInstructions = "Arrange in heart shape if possible",
                    TotalPrice = 65.00m,
                    UserId = 2
                },
                new CustomBouquet
                {
                    Id = 2,
                    Color = "Pink",
                    CardMessage = "Happy Mother's Day!",
                    SpecialInstructions = null,
                    TotalPrice = 55.00m,
                    UserId = 3
                },
                new CustomBouquet
                {
                    Id = 3,
                    Color = "Blue",
                    CardMessage = "Congratulations on your baby boy!",
                    SpecialInstructions = "Include a small teddy bear if available",
                    TotalPrice = 80.00m,
                    UserId = 3
                }
            );
        }
    }
}

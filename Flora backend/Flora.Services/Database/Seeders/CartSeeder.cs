using Microsoft.EntityFrameworkCore.Metadata.Builders;
using System;

namespace Flora.Services.Database.Seeders
{
    public static class CartSeeder
    {
        public static void SeedData(this EntityTypeBuilder<Cart> entity)
        {
            entity.HasData(
                new Cart
                {
                    Id = 1,
                    UserId = 1,
                    CreatedAt = new DateTime(2025, 7, 30)
                },
                new Cart
                {
                    Id = 2,
                    UserId = 2,
                    CreatedAt = new DateTime(2025, 7, 31)
                },
                new Cart
                {
                    Id = 3,
                    UserId = 3,
                    CreatedAt = new DateTime(2025, 8, 1)
                }
            );
        }
    }
}

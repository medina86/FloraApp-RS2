using Microsoft.EntityFrameworkCore.Metadata.Builders;
using System;

namespace Flora.Services.Database.Seeders
{
    public static class FavoriteSeeder
    {
        public static void SeedData(this EntityTypeBuilder<Favorite> entity)
        {
            entity.HasData(
                new Favorite
                {
                    Id = 1,
                    UserId = 2,
                    ProductId = 3,
                    CreatedAt = new DateTime(2025, 6, 15)
                },
                new Favorite
                {
                    Id = 2,
                    UserId = 2,
                    ProductId = 10,
                    CreatedAt = new DateTime(2025, 6, 16)
                },
                new Favorite
                {
                    Id = 3,
                    UserId = 3,
                    ProductId = 21,
                    CreatedAt = new DateTime(2025, 6, 20)
                },
                new Favorite
                {
                    Id = 4,

                    UserId = 3,
                    ProductId = 5,
                    CreatedAt = new DateTime(2025, 7, 1)
                },
                new Favorite
                {
                    Id = 5,
                    UserId = 3,
                    ProductId = 14,
                    CreatedAt = new DateTime(2025, 7, 5)
                },
                new Favorite
                {
                    Id = 6,
                    UserId = 3,
                    ProductId = 38,
                    CreatedAt = new DateTime(2025, 7, 10)
                }
            );
        }
    }
}

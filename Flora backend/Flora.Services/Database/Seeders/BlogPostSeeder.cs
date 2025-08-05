using Microsoft.EntityFrameworkCore.Metadata.Builders;
using System;

namespace Flora.Services.Database.Seeders
{
    public static class BlogPostSeeder
    {
        public static void SeedData(this EntityTypeBuilder<BlogPost> entity)
        {
            entity.HasData(
                new BlogPost
                {
                    Id = 1,
                    Title = "10 Beautiful Spring Flower Arrangements",
                    Content = "Spring is the perfect time to bring fresh flowers into your home. Here are ten beautiful arrangements that celebrate the season's blooms...",
                    CreatedAt = new DateTime(2025, 3, 15)
                },
                new BlogPost
                {
                    Id = 2,
                    Title = "How to Care for Your Houseplants",
                    Content = "Houseplants add life and beauty to any space, but they require proper care. Learn essential tips for watering, sunlight, and seasonal maintenance...",
                    CreatedAt = new DateTime(2025, 4, 10)
                },
                new BlogPost
                {
                    Id = 3,
                    Title = "Creating the Perfect Wedding Bouquet",
                    Content = "Your wedding bouquet is a crucial part of your special day. Explore different styles, seasonal options, and how to match your bouquet to your wedding theme...",
                    CreatedAt = new DateTime(2025, 5, 5)
                },
                new BlogPost
                {
                    Id = 4,
                    Title = "Flowers That Thrive in Summer Heat",
                    Content = "When temperatures rise, you need blooms that can withstand the heat. Discover gorgeous flowers that will keep your garden vibrant all summer long...",
                    CreatedAt = new DateTime(2025, 6, 20)
                },
                new BlogPost
                {
                    Id = 5,
                    Title = "The Language of Flowers: What Each Bloom Symbolizes",
                    Content = "For centuries, flowers have carried special meanings. Learn the hidden symbolism behind popular blooms to make your next gift more meaningful...",
                    CreatedAt = new DateTime(2025, 7, 12)
                }
            );
        }
    }
}

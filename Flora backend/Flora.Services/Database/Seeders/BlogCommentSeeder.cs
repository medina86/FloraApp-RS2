using Microsoft.EntityFrameworkCore.Metadata.Builders;
using System;

namespace Flora.Services.Database.Seeders
{
    public static class BlogCommentSeeder
    {
        public static void SeedData(this EntityTypeBuilder<BlogComment> entity)
        {
            entity.HasData(
                new BlogComment
                {
                    Id = 1,
                    Content = "These spring arrangements are gorgeous! I especially love the tulip and daffodil combination.",
                    CreatedAt = new DateTime(2025, 3, 16),
                    BlogPostId = 1,
                    UserId = 2
                },
                new BlogComment
                {
                    Id = 2,
                    Content = "Thanks for the houseplant tips! I've been struggling with my fiddle leaf fig and this was really helpful.",
                    CreatedAt = new DateTime(2025, 4, 11),
                    BlogPostId = 2,
                    UserId = 3
                },
                new BlogComment
                {
                    Id = 3,
                    Content = "I used your advice for my wedding last month and my bouquet was perfect! Thank you!",
                    CreatedAt = new DateTime(2025, 5, 6),
                    BlogPostId = 3,
                    UserId = 3
                },
                new BlogComment
                {
                    Id = 4,
                    Content = "Great article! I'll be sharing these summer flower tips with our customers.",
                    CreatedAt = new DateTime(2025, 6, 21),
                    BlogPostId = 4,
                    UserId = 2
                },
                new BlogComment
                {
                    Id = 5,
                    Content = "I never knew roses had such complex meanings. This will help me choose better gifts!",
                    CreatedAt = new DateTime(2025, 7, 13),
                    BlogPostId = 5,
                    UserId = 2
                }
            );
        }
    }
}

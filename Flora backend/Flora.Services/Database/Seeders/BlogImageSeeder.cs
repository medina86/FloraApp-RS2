using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Flora.Services.Database.Seeders
{
    public static class BlogImageSeeder
    {
        public static void SeedData(this EntityTypeBuilder<BlogImage> entity)
        {
            entity.HasData(
               
                new BlogImage
                {
                    Id = 1,
                    Url = "https://florablobstorage.blob.core.windows.net/profile-images/pinklillies.jpg",
                    BlogPostId = 1
                },
                new BlogImage
                {
                    Id = 2,
                    Url = "https://florablobstorage.blob.core.windows.net/profile-images/palm.png",
                    BlogPostId = 2
                },
                new BlogImage
                {
                    Id = 3,
                    Url = "https://florablobstorage.blob.core.windows.net/profile-images/weeding5.jpg",
                    BlogPostId = 3
                },
                new BlogImage
                {
                    Id = 4,
                    Url = "https://florablobstorage.blob.core.windows.net/profile-images/bluetulips.jpg",
                    BlogPostId = 4
                },
                new BlogImage
                {
                    Id = 5,
                    Url = "https://florablobstorage.blob.core.windows.net/profile-images/pinklillies.jpg",
                    BlogPostId = 5
                }
            );
        }
    }
}

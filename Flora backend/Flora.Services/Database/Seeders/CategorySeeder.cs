using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Flora.Services.Database.Seeders
{
    public static class CategorySeeder
    {
        public static void SeedData(this EntityTypeBuilder<Categories> entity)
        {
            entity.HasData(
               
                new Categories
                {
                    Id = 1,
                    Name = "Bouquets",
                    Description = "Beautifully arranged mixed flowers for all occasions.",
                    CategoryImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/pinklillies.jpg"
                },
                new Categories
                {
                    Id = 2,
                    Name = "Plants",
                    Description = "Green gifts that grow with love.",
                    CategoryImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/homeplants.png"
                },
                new Categories
                {
                    Id = 3,
                    Name = "Domes",
                    Description = "Flowers combined with chocolates, perfumes and more.",
                    CategoryImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/domesss.png"
                },
                new Categories
                {
                    Id = 4,
                    Name="Flower",
                    Description="For custom bouquets",
                    CategoryImageUrl= "https://florablobstorage.blob.core.windows.net/profile-images/flowes.png"
                },
                new Categories
                {
                    Id = 5,
                    Name="Box",
                    Description="Flower arrangements in beautiful boxes",
                    CategoryImageUrl= "https://florablobstorage.blob.core.windows.net/profile-images/box1.jpg"
                },
                new Categories
                {
                    Id = 6,
                    Name= "Gift Sets",
                    Description = "Flowers combined with chocolates, perfumes and more.",
                    CategoryImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/giftset.png"
                },
                new Categories
                {
                    Id = 7,
                    Name= "Bridal Bouquets",
                    Description= "Elegant wedding bouquets for brides",
                    CategoryImageUrl= "https://florablobstorage.blob.core.windows.net/profile-images/weeding.jpg"
                }

            );
        }
    }
}

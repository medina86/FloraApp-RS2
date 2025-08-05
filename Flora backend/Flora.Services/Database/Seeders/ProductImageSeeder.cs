using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Flora.Services.Database;

namespace Flora.Services.Database.Seeders
{
    public static class ProductImagesSeeder
    {
        public static void SeedData(this EntityTypeBuilder<ProductImages> entity)
        {
            entity.HasData(
                new ProductImages { Id = 1, ProductId = 1, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/birth.jpg" },

                new ProductImages { Id = 2, ProductId = 2, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/birth2.jpg" },

                new ProductImages { Id = 3, ProductId = 3, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/birthday.jpg" },
               
                new ProductImages { Id = 4, ProductId = 4, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/bluetulips.jpg" },

                new ProductImages { Id = 5, ProductId = 5, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/chocolateflowerdome2.jpg" },

                new ProductImages { Id = 6, ProductId = 6, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/box2.jpg" },
                
                new ProductImages { Id = 7, ProductId = 7, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/box3.jpg" },

                new ProductImages { Id = 8, ProductId = 8, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/box4.jpg" },

                new ProductImages { Id = 9, ProductId = 9, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/box5.jpg" },
                
                new ProductImages { Id = 10, ProductId = 10, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/box7.jpg" },
                
                new ProductImages { Id = 11, ProductId = 11, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/cactus.png" },

                new ProductImages { Id = 12, ProductId = 12, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/cornplant.png" },

                new ProductImages { Id = 13, ProductId = 13, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/dalias.jpg" },

                new ProductImages { Id = 14, ProductId = 14, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/flowerdome2.jpg" },

                new ProductImages { Id = 15, ProductId = 15, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/flowerdome3.jpg" },

                new ProductImages { Id = 16, ProductId = 16, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/flowerdome4.jpg" },

                new ProductImages { Id = 17, ProductId = 17, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/flowerdome6.jpg" },

                new ProductImages { Id = 18, ProductId = 18, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/flowerdomebirthday.jpg" },

                new ProductImages { Id = 19, ProductId = 19, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/flowermix1.jpg" },

                new ProductImages { Id = 20, ProductId = 20, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/flowermix2.jpg" },

                new ProductImages { Id = 21, ProductId = 21, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/flowermix3.jpg" },

                new ProductImages { Id = 22, ProductId = 22, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/gerbers.jpg" },
                
                new ProductImages { Id = 23, ProductId = 23, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/graduation.jpg" },
                
                new ProductImages { Id = 24, ProductId = 24, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/graduation2.jpg" },
                
                new ProductImages { Id = 25, ProductId = 25, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/graduation3.jpg" },
                
                new ProductImages { Id = 26, ProductId = 26, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/graduation6.jpg" },
                
                new ProductImages { Id = 27, ProductId = 22, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/hidrogenia.jpg" },

                new ProductImages { Id = 28, ProductId = 28, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/palm.png" },

                new ProductImages { Id = 29, ProductId = 29, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/peacelilly.png" },

                new ProductImages { Id = 30, ProductId = 30, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/philodendron.png" },
                
                new ProductImages { Id = 31, ProductId = 31, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/pinklillies.jpg" },
                
                new ProductImages { Id = 32, ProductId = 22, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/pinktulips.jpg" },
                
                new ProductImages { Id = 33, ProductId = 33, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/purpletulips.jpg" },
                
                new ProductImages { Id = 34, ProductId = 34, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/red%20roses.jpg" },
                
                new ProductImages { Id = 35, ProductId = 35, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/snakeplant.png" },
               
                new ProductImages { Id = 36, ProductId = 36, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/spiderplant.png" },
                
                new ProductImages { Id = 37, ProductId = 37, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/suculents.png" },
                
                new ProductImages { Id = 38, ProductId = 38, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/weeding.jpg" },
               
                new ProductImages { Id = 39, ProductId = 39, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/weeding2.jpg" },

                new ProductImages { Id = 40, ProductId = 40, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/weeding3.jpg" },

                new ProductImages { Id = 41, ProductId = 41, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/weeding4.jpg" },

                new ProductImages { Id = 42, ProductId = 42, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/weeding5.jpg" },

                new ProductImages { Id = 43, ProductId = 43, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/agb1.jpg" },
                
                new ProductImages { Id = 44, ProductId = 44, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/agb2.jpg" },

                new ProductImages { Id = 45, ProductId = 45, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/agb3.jpg" },

                new ProductImages { Id = 46, ProductId = 46, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/agb4.jpg" },
                
                new ProductImages { Id = 47, ProductId = 47, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/agb5.jpg" },

                new ProductImages { Id = 48, ProductId = 48, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/cb1.jpg" },
                new ProductImages { Id = 49, ProductId = 49, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/cb2.jpg" },
                new ProductImages { Id = 50, ProductId = 50, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/cb3.jpg" },
                new ProductImages { Id = 51, ProductId = 51, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/cb4.jpg" },
                new ProductImages { Id = 52, ProductId = 52, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/cb5.jpg" },
                new ProductImages { Id = 53, ProductId = 53, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/cb6.jpg" },
                new ProductImages { Id = 54, ProductId = 54, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/cb7.jpg" },
                new ProductImages { Id = 55, ProductId = 55, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/cb8.jpg" },
                new ProductImages { Id = 56, ProductId = 56, ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/cb9.jpg" }


            );
        }
    }
}

using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Flora.Services.Database.Seeders
{
    public static class DecorationSuggestionSeeder
    {
        public static void SeedData(this EntityTypeBuilder<DecorationSuggestion> entity)
        {
            entity.HasData(
                new DecorationSuggestion
                {
                    Id = 1,
                    DecorationRequestId = 1,
                    ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/bluetulips.jpg",
                    Description = "Elegant table centerpieces with white roses and gold accents"
                },
                new DecorationSuggestion
                {
                    Id = 2,
                    DecorationRequestId = 1,
                    ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/box1.jpg",
                    Description = "Entrance archway decorated with white orchids and gold drapery"
                },
                new DecorationSuggestion
                {
                    Id = 3,
                    DecorationRequestId = 2,
                    ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/box2.jpg",
                    Description = "Blue hydrangea centerpieces with silver accents"
                },
                new DecorationSuggestion
                {
                    Id = 4,
                    DecorationRequestId = 3,
                    ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/box3.jpg",
                    Description = "Modern arrangements with red roses and black accents, incorporating company logo"
                }
            );
        }
    }
}

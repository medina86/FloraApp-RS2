using Microsoft.EntityFrameworkCore.Metadata.Builders;
using System;

namespace Flora.Services.Database.Seeders
{
    public static class DonationCampaignSeeder
    {
        public static void SeedData(this EntityTypeBuilder<DonationCampaign> entity)
        {
            entity.HasData(
                new DonationCampaign
                {
                    Id = 1,
                    Title = "Community Garden Project",
                    Description = "Help us build a community garden in downtown Sarajevo where children can learn about plants and sustainable gardening.",
                    EndDate = new DateTime(2025, 12, 31),
                    ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/pinktulips.jpg"
                },
                new DonationCampaign
                {
                    Id = 2,
                    Title = "Flowers for Hospitals",
                    Description = "Donate to help us deliver fresh flowers to patients in local hospitals, bringing joy and color to those who need it most.",
                    EndDate = new DateTime(2025, 10, 15),
                    ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/pinktulips.jpg"
                },
                new DonationCampaign
                {
                    Id = 3,
                    Title = "School Gardening Education",
                    Description = "Support our initiative to teach gardening in schools, providing students with hands-on experience growing plants and flowers.",
                    EndDate = new DateTime(2026, 05, 30),
                    ImageUrl = "https://florablobstorage.blob.core.windows.net/profile-images/pinktulips.jpg"
                }
            );
        }
    }
}

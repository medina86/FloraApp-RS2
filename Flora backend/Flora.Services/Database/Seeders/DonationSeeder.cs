using Microsoft.EntityFrameworkCore.Metadata.Builders;
using System;

namespace Flora.Services.Database.Seeders
{
    public static class DonationSeeder
    {
        public static void SeedData(this EntityTypeBuilder<Donation> entity)
        {
            entity.HasData(
                new Donation
                {
                    Id = 1,
                    UserId = 2,
                    DonorName = "Maja",
                    Email = "maja@example.com",
                    Amount = 50.00,
                    Purpose = "Community Garden Project",
                    Date = new DateTime(2025, 7, 15),
                    TransactionId = "PAY-1DX87612GH298734K",
                    Status = "Completed",
                    CampaignId = 1
                },
                new Donation
                {
                    Id = 2,
                    UserId = 3,
                    DonorName = "Amina",
                    Email = "amina@example.com",
                    Amount = 25.00,
                    Purpose = "Flowers for Hospitals",
                    Date = new DateTime(2025, 7, 20),
                    TransactionId = "PAY-9HG76354KJ298345L",
                    Status = "Completed",
                    CampaignId = 2
                },
                new Donation
                {
                    Id = 3,
                    UserId = 3,
                    DonorName = "Emina",
                    Email = "emina@example.com",
                    Amount = 100.00,
                    Purpose = "School Gardening Education",
                    Date = new DateTime(2025, 7, 25),
                    TransactionId = "PAY-7JH98345KL456789M",
                    Status = "Completed",
                    CampaignId = 3
                },
                new Donation
                {
                    Id = 4,
                    UserId = 2,
                    DonorName = "Medin",
                    Email = "medin@example.com",
                    Amount = 75.00,
                    Purpose = "Community Garden Project",
                    Date = new DateTime(2025, 7, 28),
                    TransactionId = "PAY-2KL87345JH765432N",
                    Status = "Completed",
                    CampaignId = 1
                }
            );
        }
    }
}

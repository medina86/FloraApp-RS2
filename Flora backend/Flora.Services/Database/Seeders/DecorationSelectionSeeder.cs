using Microsoft.EntityFrameworkCore.Metadata.Builders;
using System;

namespace Flora.Services.Database.Seeders
{
    public static class DecorationSelectionSeeder
    {
        public static void SeedData(this EntityTypeBuilder<DecorationSelection> entity)
        {
            entity.HasData(
                new DecorationSelection
                {
                    Id = 1,
                    DecorationRequestId = 1,
                    DecorationSuggestionId = 1,
                    UserId = 2,
                    Comments = "I love this design! Can we add a few more roses to each centerpiece?",
                    CreatedAt = new DateTime(2025, 7, 20, 14, 30, 0),
                    Status = "Selected"
                },
                new DecorationSelection
                {
                    Id = 2,
                    DecorationRequestId = 2,
                    DecorationSuggestionId = 3,
                    UserId = 3,
                    Comments = "Perfect! Please make sure the blue matches the invitations I sent.",
                    CreatedAt = new DateTime(2025, 7, 25, 10, 15, 0),
                    Status = "Selected"
                }
                // Request 3 doesn't have a selection yet
            );
        }
    }
}

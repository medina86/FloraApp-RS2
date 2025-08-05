using Microsoft.EntityFrameworkCore.Metadata.Builders;
using System;

namespace Flora.Services.Database.Seeders
{
    public static class DecorationRequestSeeder
    {
        public static void SeedData(this EntityTypeBuilder<DecorationRequest> entity)
        {
            entity.HasData(
                new DecorationRequest
                {
                    Id = 1,
                    EventType = "Wedding",
                    EventDate = new DateTime(2025, 9, 15),
                    VenueType = "Hotel Ballroom",
                    NumberOfGuests = 150,
                    NumberOfTables = 20,
                    ThemeOrColors = "White and Gold",
                    Location = "Sarajevo",
                    SpecialRequests = "Bride is allergic to lilies, please avoid using them",
                    Budget = 2000.00m,
                    UserId = 2
                },
                new DecorationRequest
                {
                    Id = 2,
                    EventType = "Birthday Party",
                    EventDate = new DateTime(2025, 8, 10),
                    VenueType = "Restaurant",
                    NumberOfGuests = 50,
                    NumberOfTables = 8,
                    ThemeOrColors = "Blue and Silver",
                    Location = "Mostar",
                    SpecialRequests = "Need table centerpieces and entrance decoration",
                    Budget = 500.00m,
                    UserId = 3
                },
                new DecorationRequest
                {
                    Id = 3,
                    EventType = "Corporate Event",
                    EventDate = new DateTime(2025, 11, 20),
                    VenueType = "Conference Hall",
                    NumberOfGuests = 200,
                    NumberOfTables = 25,
                    ThemeOrColors = "Company colors: Red and Black",
                    Location = "Tuzla",
                    SpecialRequests = "Need stage decoration and branded floral arrangements",
                    Budget = 1500.00m,
                    UserId = 3
                }
            );
        }
    }
}

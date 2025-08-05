using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Flora.Services.Database.Seeders
{
    public static class ShippingAddressSeeder
    {
        public static void SeedData(this EntityTypeBuilder<ShippingAddress> entity)
        {
            entity.HasData(
                new ShippingAddress
                {
                    Id = 1,
                    FirstName = "Maja",
                    LastName = "Hodžić",
                    City = "Sarajevo",
                    Street = "Zmaja od Bosne",
                    HouseNumber = "10",
                    PostalCode = "71000",
                    OrderNote = "Please call before delivery"
                },
                new ShippingAddress
                {
                    Id = 2,
                    FirstName = "Amina",
                    LastName = "Delić",
                    City = "Mostar",
                    Street = "Kralja Tvrtka",
                    HouseNumber = "15",
                    PostalCode = "88000",
                    OrderNote = "Leave at reception"
                },
                new ShippingAddress
                {
                    Id = 3,
                    FirstName = "Emina",
                    LastName = "Jahić",
                    City = "Tuzla",
                    Street = "Pozorišna",
                    HouseNumber = "8",
                    PostalCode = "75000",
                    OrderNote = null
                },
                new ShippingAddress
                {
                    Id = 4,
                    FirstName = "Medin",
                    LastName = "Mujkić",
                    City = "Zenica",
                    Street = "Maršala Tita",
                    HouseNumber = "22",
                    PostalCode = "72000",
                    OrderNote = "Apartment 3, 2nd floor"
                }
            );
        }
    }
}

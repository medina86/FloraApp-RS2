using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Flora.Services.Database.Seeders
{
    public static class OccasionSeeder
    {
        public static void SeedData(this EntityTypeBuilder<Occasion> entity)
        {
            entity.HasData(
                new Occasion { OccasionId = 1, Name = "Birthday" },
                new Occasion { OccasionId = 2, Name = "Newborns" },
                new Occasion { OccasionId = 3, Name = "Graduation" }
            );
        }
    }
}

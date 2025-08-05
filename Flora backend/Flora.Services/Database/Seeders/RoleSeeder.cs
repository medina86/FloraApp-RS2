using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Flora.Services.Database;
using System;

namespace Flora.Services.Database.Seeders
{
    public static class RoleSeeder
    {
        public static void SeedData(this EntityTypeBuilder<Role> entity)
        {
            entity.HasData(
                new Role
                {
                    Id = 1,
                    Name = "Admin",
                    Description = "Administrator role",
                    IsActive = true,
                    CreatedAt = new DateTime(2025, 8, 5)
                },
                new Role
                {
                    Id = 2,
                    Name = "User",
                    Description = "Standard user role",
                    IsActive = true,
                    CreatedAt = new DateTime(2025, 8, 5)
                }
            );
        }
    }
}

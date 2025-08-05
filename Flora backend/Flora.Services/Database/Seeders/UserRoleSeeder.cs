using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Flora.Services.Database;
using System;

namespace Flora.Services.Database.Seeders
{
    public static class UserRoleSeeder
    {
        public static void SeedData(this EntityTypeBuilder<UserRole> entity)
        {
            var assignedDate = new DateTime(2025, 8, 5);

            entity.HasData(
                new UserRole { Id = 1, UserId = 1, RoleId = 1, DateAssigned = assignedDate },
                new UserRole { Id = 2, UserId = 2, RoleId = 2, DateAssigned = assignedDate },
                new UserRole { Id = 3, UserId = 3, RoleId = 2, DateAssigned = assignedDate }
            );
        }
    }
}

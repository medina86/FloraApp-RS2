using System;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using System.Security.Cryptography;
using Flora.Services.Database;

namespace Flora.Services.Database.Seeders
{
    public static class UserSeeder
    {
        public static void SeedData(this EntityTypeBuilder<User> entity)
        {
            
            string adminSalt;
            string adminHash = HashPassword("admin123", out adminSalt);

            string userSalt;
            string userHash = HashPassword("user123", out userSalt);

            string user1Salt;
            string user1Hash = HashPassword("medina123", out user1Salt);

            entity.HasData(
                new User
                {
                    Id = 1,
                    FirstName = "Admin",
                    LastName = "Admin",
                    Email = "admin@flora.com",
                    Username = "admin",
                    PasswordHash = adminHash,
                    PasswordSalt = adminSalt,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                new User
                {
                    Id = 2,
                    FirstName = "User",
                    LastName = "User",
                    Email = "user@flora.com",
                    Username = "user",
                    PasswordHash = userHash,
                    PasswordSalt = userSalt,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                new User
                {
                    Id = 3,
                    FirstName = "Medina",
                    LastName = "Krhan",
                    Email = "medina@flora.com",
                    Username = "medina",
                    PasswordHash = user1Hash,
                    PasswordSalt = user1Salt,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                }
            );
        }

        private static string HashPassword(string password, out string salt)
        {
            const int SaltSize = 16;
            const int KeySize = 32;
            const int Iterations = 10000;

            byte[] saltBytes = new byte[SaltSize];
            using (var rng = new RNGCryptoServiceProvider())
            {
                rng.GetBytes(saltBytes);
                salt = Convert.ToBase64String(saltBytes);
            }

            using (var pbkdf2 = new Rfc2898DeriveBytes(password, saltBytes, Iterations))
            {
                return Convert.ToBase64String(pbkdf2.GetBytes(KeySize));
            }
        }
    }
}

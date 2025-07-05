using Flora.Models.Requests;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using Flora.Services.Database;
using Flora.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Services.Services
{
    public class UserService : IUserService
    {
        private readonly FLoraDbContext _context;
        private const int SaltSize = 16;
        private const int KeySize = 32;
        private const int Iterations = 10000;

        public UserService(FLoraDbContext context)
        {
            _context = context;
        }

        public async Task<List<UserResponse>> GetAsync(UserSearchObject search)
        {
            var query = _context.Users.AsQueryable();

            if (!string.IsNullOrEmpty(search.Username))
            {
                query = query.Where(u => u.Username.Contains(search.Username));
            }

            if (!string.IsNullOrEmpty(search.Email))
            {
                query = query.Where(u => u.Email.Contains(search.Email));
            }

            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(u =>
                    u.FirstName.Contains(search.FTS) ||
                    u.LastName.Contains(search.FTS) ||
                    u.Username.Contains(search.FTS) ||
                    u.Email.Contains(search.FTS));
            }

            var users = await query.ToListAsync();
            return users.Select(MapToResponse).ToList();
        }

        public async Task<UserResponse?> GetByIdAsync(int id)
        {
            var user = await _context.Users.FindAsync(id);
            return user != null ? MapToResponse(user) : null;
        }

        private string HashPassword(string password, out byte[] salt)
        {
            salt = new byte[SaltSize];
            using (var rng = new RNGCryptoServiceProvider())
            {
                rng.GetBytes(salt);
            }

            using (var pbkdf2 = new Rfc2898DeriveBytes(password, salt, Iterations))
            {
                return Convert.ToBase64String(pbkdf2.GetBytes(KeySize));
            }
        }

        public async Task<UserResponse> CreateAsync(UserRequest request)
        {
            if (await _context.Users.AnyAsync(u => u.Email == request.Email))
            {
                throw new InvalidOperationException("A user with this email already exists.");
            }

            if (await _context.Users.AnyAsync(u => u.Username == request.Username))
            {
                throw new InvalidOperationException("A user with this username already exists.");
            }

            var user = new User
            {
                FirstName = request.FirstName,
                LastName = request.LastName,
                Email = request.Email,
                Username = request.Username,
                PhoneNumber = request.PhoneNumber,
                IsActive = request.IsActive,
                CreatedAt = DateTime.UtcNow
            };

            if (!string.IsNullOrEmpty(request.Password))
            {
                byte[] salt;
                user.PasswordHash = HashPassword(request.Password, out salt);
                user.PasswordSalt = Convert.ToBase64String(salt);
            }

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            if (request.RoleIds != null && request.RoleIds.Count > 0)
            {
                foreach (var roleId in request.RoleIds)
                {
                    if (await _context.Roles.AnyAsync(r => r.Id == roleId))
                    {
                        var userRole = new UserRole
                        {
                            UserId = user.Id,
                            RoleId = roleId,
                            DateAssigned = DateTime.UtcNow
                        };
                        _context.UserRoles.Add(userRole);
                    }
                }
                await _context.SaveChangesAsync();
            }

            return await GetUserResponseWithRolesAsync(user.Id);
        }

        public async Task<UserResponse?> UpdateAsync(int id, UserRequest request)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null)
                return null;

            if (await _context.Users.AnyAsync(u => u.Email == request.Email && u.Id != id))
            {
                throw new InvalidOperationException("A user with this email already exists.");
            }

            if (await _context.Users.AnyAsync(u => u.Username == request.Username && u.Id != id))
            {
                throw new InvalidOperationException("A user with this username already exists.");
            }

            user.FirstName = request.FirstName;
            user.LastName = request.LastName;
            user.Email = request.Email;
            user.Username = request.Username;
            user.PhoneNumber = request.PhoneNumber;
            user.IsActive = request.IsActive;

            if (!string.IsNullOrEmpty(request.Password))
            {
                byte[] salt;
                user.PasswordHash = HashPassword(request.Password, out salt);
                user.PasswordSalt = Convert.ToBase64String(salt);
            }

            var existingUserRoles = await _context.UserRoles.Where(ur => ur.UserId == id).ToListAsync();
            _context.UserRoles.RemoveRange(existingUserRoles);

            if (request.RoleIds != null && request.RoleIds.Count > 0)
            {
                foreach (var roleId in request.RoleIds)
                {
                    if (await _context.Roles.AnyAsync(r => r.Id == roleId))
                    {
                        var userRole = new UserRole
                        {
                            UserId = user.Id,
                            RoleId = roleId,
                            DateAssigned = DateTime.UtcNow
                        };
                        _context.UserRoles.Add(userRole);
                    }
                }
            }

            await _context.SaveChangesAsync();
            return await GetUserResponseWithRolesAsync(user.Id);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null)
                return false;

            _context.Users.Remove(user);
            await _context.SaveChangesAsync();
            return true;
        }
        public async Task UpdateProfileImageUrl(int userId, string imageUrl)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null)
                throw new InvalidOperationException("User not found.");

            user.ProfileImageUrl = imageUrl;
            await _context.SaveChangesAsync();
        }

        private UserResponse MapToResponse(User user)
        {
            return new UserResponse
            {
                Id = user.Id,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Email = user.Email,
                Username = user.Username,
                PhoneNumber = user.PhoneNumber,
                IsActive = user.IsActive,
                CreatedAt = user.CreatedAt,
                LastLoginAt = user.LastLoginAt
            };
        }

        private async Task<UserResponse> GetUserResponseWithRolesAsync(int userId)
        {
            var user = await _context.Users
                .Include(u => u.UserRoles)
                .ThenInclude(ur => ur.Role)
                .FirstOrDefaultAsync(u => u.Id == userId);

            if (user == null)
                throw new InvalidOperationException("User not found");

            var response = MapToResponse(user);

            response.Roles = user.UserRoles
                .Where(ur => ur.Role.IsActive)
                .Select(ur => new RoleResponse
                {
                    Id = ur.Role.Id,
                    Name = ur.Role.Name,
                    Description = ur.Role.Description
                })
                .ToList();

            return response;
        }

        public async Task<UserResponse?> AuthenticateAsync(UserLoginRequest request)
        {
            var user = await _context.Users
                .Include(u => u.UserRoles)
                .ThenInclude(ur => ur.Role)
                .FirstOrDefaultAsync(u => u.Username == request.Username);

            if (user == null)
                return null;

            if (!VerifyPassword(request.Password!, user.PasswordHash, user.PasswordSalt))
                return null;

            user.LastLoginAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            var response = MapToResponse(user);

            response.Roles = user.UserRoles
                .Where(ur => ur.Role.IsActive)
                .Select(ur => new RoleResponse
                {
                    Id = ur.Role.Id,
                    Name = ur.Role.Name,
                    Description = ur.Role.Description
                })
                .ToList();

            return response;
        }
        private bool VerifyPassword(string password, string passwordHash, string passwordSalt)
        {
            var salt = Convert.FromBase64String(passwordSalt);
            var hash = Convert.FromBase64String(passwordHash);
            var hashBytes = new Rfc2898DeriveBytes(password, salt, Iterations).GetBytes(KeySize);
            return hash.SequenceEqual(hashBytes);
        }
    }
}

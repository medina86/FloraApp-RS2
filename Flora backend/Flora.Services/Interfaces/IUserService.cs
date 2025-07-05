using Flora.Models.Requests;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Services.Interfaces
{
    public interface IUserService
    {
        Task<List<UserResponse>> GetAsync(UserSearchObject search);
        Task<UserResponse?> GetByIdAsync(int id);
        Task<UserResponse> CreateAsync(UserRequest request);
        Task<UserResponse?> UpdateAsync(int id, UserRequest request);
        Task<bool> DeleteAsync(int id);
        Task<UserResponse?> AuthenticateAsync(UserLoginRequest request);
        Task UpdateProfileImageUrl(int userId, string profileImageUrl);
    }
}

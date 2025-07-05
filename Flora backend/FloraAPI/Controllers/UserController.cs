using Flora.Models.Requests;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using Flora.Services.Interfaces;
using Flora.Services.Services;
using Microsoft.AspNetCore.Mvc;

namespace FloraAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UsersController : ControllerBase
    {
        private readonly IUserService _userService;
        private readonly IBlobService _blobService;
        public UsersController(IUserService userService, IBlobService blobService)
        {
            _userService = userService;
            _blobService = blobService;
        }

        [HttpGet]
        public async Task<ActionResult<List<UserResponse>>> Get([FromQuery] UserSearchObject? search = null)
        {
            return await _userService.GetAsync(search ?? new UserSearchObject());
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<UserResponse>> GetById(int id)
        {
            var user = await _userService.GetByIdAsync(id);

            if (user == null)
                return NotFound();

            return user;
        }

        [HttpPost]
        public async Task<ActionResult<UserResponse>> Create(UserRequest request)
        {
            var createdUser = await _userService.CreateAsync(request);
            return CreatedAtAction(nameof(GetById), new { id = createdUser.Id }, createdUser);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<UserResponse>> Update(int id, UserRequest request)
        {
            var updatedUser = await _userService.UpdateAsync(id, request);

            if (updatedUser == null)
                return NotFound();

            return updatedUser;
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult> Delete(int id)
        {
            var deleted = await _userService.DeleteAsync(id);

            if (!deleted)
                return NotFound();

            return NoContent();
        }
        [HttpPost("login")]
        public async Task<ActionResult<UserResponse>> Login(UserLoginRequest request)
        {
            var user = await _userService.AuthenticateAsync(request);
            return Ok(user);
        }
        [HttpPost("{id}/upload-image")]
        public async Task<IActionResult> UploadProfileImage(int id, IFormFile file)
        {
            var user = await _userService.GetByIdAsync(id);
            if (user == null)
                return NotFound();

            if (file == null || file.Length == 0)
                return BadRequest("No file uploaded.");

            var imageUrl = await _blobService.UploadFileAsync(file);
            await _userService.UpdateProfileImageUrl(id, imageUrl);

            return Ok(new { imageUrl });
        }
    }
}

using Flora.Models.Requests;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using Flora.Services.Interfaces;
using FloraAPI.Controllers;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Flora.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class BlogPostController : BaseCRUDController<BlogPostResponse, BlogPostSearchObject, BlogPostRequest, BlogPostRequest>
    {
        private readonly IBlogPostService _blogPostService;

        public BlogPostController(IBlogPostService blogPostService)
            : base(blogPostService)
        {
            _blogPostService = blogPostService;
        }

        // CREATE
        [HttpPost]
        public override async Task<BlogPostResponse> Create([FromForm] BlogPostRequest request)
        {
            return await _blogPostService.CreateAsync(request);
        }
        [HttpPut("{id}")]
        public override async Task<BlogPostResponse> Update(int id, [FromForm] BlogPostRequest request)
        {
            return await _blogPostService.UpdateAsync(id, request);
        }

    }
}

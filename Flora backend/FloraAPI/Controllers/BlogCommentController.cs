using Flora.Models.Requests;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using Flora.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FloraAPI.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class BlogCommentController : BaseCRUDController<BlogCommentResponse, BlogCommentSearchObject, BlogCommentRequest, BlogCommentRequest>
    {
        public BlogCommentController(IBlogCommentService service) : base(service) { }
    }

}
    
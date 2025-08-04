using Flora.Models.Requests;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using Flora.Services.Database;
using Flora.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Services.Services
{
    public class BlogCommentService : BaseCRUDService<BlogCommentResponse, BlogCommentSearchObject, BlogComment, BlogCommentRequest, BlogCommentRequest>, IBlogCommentService
    {
        public BlogCommentService(FLoraDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }
        protected override IQueryable<BlogComment> ApplyFilter(IQueryable<BlogComment> query, BlogCommentSearchObject search)
        {
            query = query.Include(b => b.User).Include(b => b.BlogPost);

            if (search?.BlogPostId.HasValue==true)
            {
                query = query.Where(d => d.BlogPostId == search.BlogPostId.Value);
            }

            return query.OrderByDescending(b => b.CreatedAt);
        }
        protected override BlogCommentResponse MapToResponse(BlogComment entity)
        {
            return new BlogCommentResponse
            {
                Id = entity.Id,
                AuthorName=entity.User.Username,
                Content = entity.Content,
                CreatedAt=entity.CreatedAt
            };
        }


    }

}

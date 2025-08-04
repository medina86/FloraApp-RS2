using Flora.Models.Requests;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using Flora.Services.Database;
using Flora.Services.Interfaces;
using MapsterMapper;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Flora.Services.Services
{
    public class BlogPostService : BaseCRUDService<BlogPostResponse, BlogPostSearchObject, BlogPost, BlogPostRequest, BlogPostRequest>, IBlogPostService
    {
        private readonly IBlobService _blobService;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public BlogPostService(FLoraDbContext context, IMapper mapper, IBlobService blobService, IHttpContextAccessor httpContextAccessor)
            : base(context, mapper)
        {
            _blobService = blobService;
            _httpContextAccessor = httpContextAccessor;
        }

        public override async Task<BlogPostResponse> CreateAsync(BlogPostRequest request)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();

            try
            {
                var entity = _mapper.Map<BlogPost>(request);
                await BeforeInsert(entity, request);

                _context.BlogPosts.Add(entity);
                await _context.SaveChangesAsync();

                if (request.Images != null)
                {
                    foreach (var image in request.Images)
                    {
                        var imageUrl = await _blobService.UploadFileAsync(image);
                        var blogImage = new BlogImage
                        {
                            BlogPostId = entity.Id,
                            Url = imageUrl
                        };
                        _context.BlogImages.Add(blogImage);
                    }
                    await _context.SaveChangesAsync();
                }

                await transaction.CommitAsync();
                return await GetByIdAsync(entity.Id) ?? throw new Exception("Blog post not found after creation.");
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }
        }

        public override async Task<BlogPostResponse?> GetByIdAsync(int id)
        {
            var blog = await _context.BlogPosts
                .Include(b => b.Images)
                .Include(b => b.Comments)
                    .ThenInclude(c => c.User)
                .FirstOrDefaultAsync(b => b.Id == id);

            return blog == null ? null : MapToResponse(blog);
        }

        public override async Task<BlogPostResponse?> UpdateAsync(int id, BlogPostRequest request)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();

            try
            {
                var blog = await _context.BlogPosts
                    .Include(b => b.Images)
                    .FirstOrDefaultAsync(b => b.Id == id);

                if (blog == null)
                    throw new Exception("Blog post not found.");

                blog.Title = request.Title;
                blog.Content = request.Content;
                blog.CreatedAt = DateTime.UtcNow;

                // Delete old images if needed
                _context.BlogImages.RemoveRange(blog.Images);

                // Add new images
                if (request.Images != null)
                {
                    foreach (var image in request.Images)
                    {
                        var url = await _blobService.UploadFileAsync(image);
                        blog.Images.Add(new BlogImage { Url = url });
                    }
                }

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                return MapToResponse(blog);
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }
        }

        protected override async Task BeforeInsert(BlogPost entity, BlogPostRequest request)
        {
            entity.CreatedAt = DateTime.UtcNow;
            entity.CreatedAt = DateTime.UtcNow;

            var context = _httpContextAccessor.HttpContext;
            if (context == null)
                throw new Exception("No HTTP context found.");

   
        }

        protected override BlogPostResponse MapToResponse(BlogPost entity)
        {
            var response = _mapper.Map<BlogPostResponse>(entity);

            response.ImageUrls = entity.Images?.Select(img => img.Url).ToList() ?? new();
            response.Comments = entity.Comments?.Select(c => new BlogCommentResponse
            {
                Id = c.Id,
                Content = c.Content,
                CreatedAt = c.CreatedAt,
                AuthorName = c.User?.FirstName + " " + c.User?.LastName
            }).ToList() ?? new();

            return response;
        }

        protected override IQueryable<BlogPost> ApplyFilter(IQueryable<BlogPost> query, BlogPostSearchObject search)
        {
            query = query.Include(b => b.Images).Include(b => b.Comments);

            if (!string.IsNullOrWhiteSpace(search?.FTS))
            {
                var term = search.FTS.ToLower();
                query = query.Where(b => b.Title.ToLower().Contains(term) || b.Content.ToLower().Contains(term));
            }

            return query.OrderByDescending(b => b.CreatedAt);
        }
    }
}

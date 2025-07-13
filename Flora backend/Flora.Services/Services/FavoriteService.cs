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
    public class FavoriteService : BaseCRUDService<FavoriteResponse,FavoriteSearchObject,Database.Favorite,FavoriteRequest, FavoriteRequest>, IFavoriteService
    {
        public FavoriteService(FLoraDbContext context, IMapper mapper): base(context, mapper) { }
        public async Task<List<int>> GetFavoriteProductIdsByUserAsync(int userId)
        {
            return await _context.Favorites
                .Where(f => f.UserId == userId)
                .Select(f => f.ProductId)
                .ToListAsync();
        }
        protected override IQueryable<Favorite> ApplyFilter(IQueryable<Favorite> query, FavoriteSearchObject search)
        {
            query = query
                .Include(f => f.Product)
                    .ThenInclude(p => p.Images);

            if (search.UserId.HasValue)
            {
                query = query.Where(f => f.UserId == search.UserId.Value);
            }
           

            return query;
        }

        protected override FavoriteResponse MapToResponse(Favorite entity)
        {
            return new FavoriteResponse
            {
                FavoriteId=entity.Id,
                ProductId = entity.ProductId,
                ProductName = entity.Product?.Name,
                Description = entity.Product?.Description,
                Price = entity.Product?.Price ?? 0,
                ImageUrls = entity.Product?.Images?.Select(img => img.ImageUrl).ToList() ?? new List<string>()
            };
        }


    }
}

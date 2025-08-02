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
    public class CustomBouquetService : BaseCRUDService<
    CustomBouquetResponse, CustomBouquetSearchObject, CustomBouquet, CustomBouquetRequest, CustomBouquetRequest>, ICustomBouquetService
    {
        private readonly FLoraDbContext _context;

        public CustomBouquetService(FLoraDbContext context, IMapper mapper)
            : base(context, mapper)
        {
            _context = context;
        }

        protected override async Task BeforeInsert(CustomBouquet entity, CustomBouquetRequest request)
        {
            entity.UserId = request.UserId;
            entity.Items = request.CustomBouquetItems.Select(i => new CustomBouquetItem
            {
                ProductId = i.ProductId,
                Quantity = i.Quantity
            }).ToList();
        }
        public override async Task<CustomBouquetResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.CustomBouquets
                .Include(cb => cb.Items)
                    .ThenInclude(i => i.Product)
                .FirstOrDefaultAsync(cb => cb.Id == id);

            if (entity == null)
                return null;

            return MapToResponse(entity);
        }
        public override async Task<PagedResult<CustomBouquetResponse>> GetAsync(CustomBouquetSearchObject search)
        {
            var query = _context.CustomBouquets
                .Include(cb => cb.Items)
                    .ThenInclude(i => i.Product)
                .AsQueryable();

            query = ApplyFilter(query, search);

            int? totalCount = null;
            if (search.IncludeTotalCount)
            {
                totalCount = await query.CountAsync();
            }

            if (!search.RetrieveAll)
            {
                if (search.Page.HasValue)
                {
                    query = query.Skip(search.Page.Value * search.PageSize.Value);
                }
                if (search.PageSize.HasValue)
                {
                    query = query.Take(search.PageSize.Value);
                }
            }

            var list = await query.ToListAsync();

            return new PagedResult<CustomBouquetResponse>
            {
                Items = list.Select(MapToResponse).ToList(),
                TotalCount = totalCount
            };
        }


        protected override CustomBouquetResponse MapToResponse(CustomBouquet entity)
        {
            return new CustomBouquetResponse
            {
                Id = entity.Id,
                Color = entity.Color,
                CardMessage = entity.CardMessage,
                SpecialInstructions = entity.SpecialInstructions,
                TotalPrice = entity.TotalPrice,
                Items = entity.Items.Where(i => i.Product != null).Select(i => new CustomBouquetItemResponse
                {
                    ProductId = i.ProductId,
                    ProductName = i.Product.Name ?? "",
                    Quantity = i.Quantity
                }).ToList()
            };
        }
    }

}

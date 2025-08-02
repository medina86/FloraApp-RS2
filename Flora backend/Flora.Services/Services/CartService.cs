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
    public class CartService : BaseCRUDService<CartResponse, CartSearchObject, Database.Cart, CartRequest, CartRequest>, ICartService
    {
        public CartService(FLoraDbContext context, IMapper mapper) : base(context, mapper) { }

        protected override IQueryable<Cart> ApplyFilter(IQueryable<Cart> query, CartSearchObject search)
        {
            query = query
                .Include(c => c.Items)
                    .ThenInclude(i => i.Product)
                        .ThenInclude(p => p.Images)
                .Include(c => c.Items)
                    .ThenInclude(i => i.CustomBouquet); // Dodano za CustomBouquet

            if (search?.UserId.HasValue == true)
            {
                query = query.Where(c => c.UserId == search.UserId.Value);
            }

            return query;
        }

        protected override CartResponse MapToResponse(Cart entity)
        {
            return new CartResponse
            {
                Id = entity.Id,
                UserId = entity.UserId,
                CreatedAt = entity.CreatedAt,
                TotalAmount = entity.Items?.Sum(i => GetItemPrice(i) * i.Quantity) ?? 0,
                Items = entity.Items?.Select(i => new CartItemResponse
                {
                    Id = i.Id,
                    ProductId = i.ProductId?? 0, 
                    ProductName = " ",
                    Price = GetItemPrice(i),
                    Quantity = i.Quantity,
                    CardMessage = i.CardMessage,
                    SpecialInstructions = i.SpecialInstructions,
                    ImageUrl = GetItemImageUrl(i)
                }).ToList() ?? new List<CartItemResponse>()
            };
        }

        

        private decimal GetItemPrice(CartItem item)
        {
            if (item.Product != null)
                return item.Product.Price;

            if (item.CustomBouquet != null)
                return item.CustomBouquet.TotalPrice;

            return 0;
        }

        private string GetItemImageUrl(CartItem item)
        {
            if (item.Product?.Images != null)
                return item.Product.Images.FirstOrDefault()?.ImageUrl;

            return null;
        }
    }
}
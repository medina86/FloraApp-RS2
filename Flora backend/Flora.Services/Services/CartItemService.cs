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
    public class CartItemService : BaseCRUDService<CartItemResponse,CartItemSearchObject, Database.CartItem, CartItemRequest,CartItemRequest>, ICartItemService
    {
        private readonly FLoraDbContext _context;
        public CartItemService(FLoraDbContext context, IMapper mapper) : base(context, mapper){
            _context = context;
        }
        protected override IQueryable<CartItem> ApplyFilter(IQueryable<CartItem> query, CartItemSearchObject search)
        {
            query = query
                .Include(ci => ci.Product).ThenInclude(p=>p.Images); 

            if (search.CartId.HasValue)
                query = query.Where(ci => ci.CartId == search.CartId.Value);

            return query;
        }
        protected override async Task BeforeInsert(CartItem entity, CartItemRequest request)
        {
            var product = await _context.Products
                .Include(p => p.Images) 
                .FirstOrDefaultAsync(p => p.Id == request.ProductId);

            if (product != null)
            {
                entity.ProductName = product.Name;
                entity.Price = product.Price;
                entity.ImageUrl = product.Images?.FirstOrDefault()?.ImageUrl;
            }
        }
        public async Task<CartItemResponse?> IncreaseQuantityAsync(int id)
        {
            var cartItem = await _context.CartItems
                .Include(ci => ci.Product)
                    .ThenInclude(p => p.Images)
                .FirstOrDefaultAsync(ci => ci.Id == id);

            if (cartItem == null)
                return null;

            cartItem.Quantity += 1;
            await _context.SaveChangesAsync();

            return new CartItemResponse
            {
                Id = cartItem.Id,
                ProductId = cartItem.Product.Id,
                ProductName = cartItem.Product.Name,
                Price = cartItem.Product.Price,
                Quantity = cartItem.Quantity,
                CardMessage = cartItem.CardMessage,
                SpecialInstructions = cartItem.SpecialInstructions,
                ImageUrl = cartItem.Product.Images?.FirstOrDefault()?.ImageUrl
            };
        }

        public async Task<(CartItemResponse? response, bool removed)> DecreaseQuantityAsync(int id)
        {
            var cartItem = await _context.CartItems
                .Include(ci => ci.Product)
                    .ThenInclude(p => p.Images)
                .FirstOrDefaultAsync(ci => ci.Id == id);

            if (cartItem == null)
                return (null, false);

            if (cartItem.Quantity <= 1)
            {
                _context.CartItems.Remove(cartItem);
                await _context.SaveChangesAsync();
                return (null, true);
            }

            cartItem.Quantity -= 1;
            await _context.SaveChangesAsync();

            var response = new CartItemResponse
            {
                Id = cartItem.Id,
                ProductId = cartItem.Product.Id,
                ProductName = cartItem.Product.Name,
                Price = cartItem.Product.Price,
                Quantity = cartItem.Quantity,
                CardMessage = cartItem.CardMessage,
                SpecialInstructions = cartItem.SpecialInstructions,
                ImageUrl = cartItem.Product.Images?.FirstOrDefault()?.ImageUrl
            };

            return (response, false);
        }
        protected override CartItemResponse MapToResponse(CartItem entity)
        {
            return new CartItemResponse
            {
                Id = entity.Id,
                ProductId = entity.ProductId,
                ProductName = entity.Product?.Name,
                Price = entity.Product.Price,
                Quantity = entity.Quantity,
                CardMessage = entity.CardMessage,
                SpecialInstructions = entity.SpecialInstructions,
                ImageUrl = entity.Product?.Images?.FirstOrDefault()?.ImageUrl 
            };
        }


    }
}

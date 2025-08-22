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
    public class CartItemService : BaseCRUDService<CartItemResponse, CartItemSearchObject, Database.CartItem, CartItemRequest, CartItemRequest>, ICartItemService
    {
        private readonly FLoraDbContext _context;
        public CartItemService(FLoraDbContext context, IMapper mapper) : base(context, mapper)
        {
            _context = context;
        }

        protected override IQueryable<CartItem> ApplyFilter(IQueryable<CartItem> query, CartItemSearchObject search)
        {
            query = query
                .Include(ci => ci.Product)
                    .ThenInclude(p => p.Images)
                .Include(ci => ci.CustomBouquet); 

            if (search?.CartId.HasValue == true)
                query = query.Where(ci => ci.CartId == search.CartId.Value);

            return query;
        }

        protected override async Task BeforeInsert(CartItem entity, CartItemRequest request)
        {
            if (request.ProductId == null && request.CustomBouquetId == null)
                throw new Exception("CartItem must have either ProductId or CustomBouquetId.");

            if (request.ProductId != null && request.ProductId != 0)
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
            else if (request.CustomBouquetId.HasValue)
            {
                var bouquet = await _context.CustomBouquets
                    .FirstOrDefaultAsync(b => b.Id == request.CustomBouquetId.Value);

                if (bouquet != null)
                {
                    entity.ProductName = "Custom Bouquet";
                    entity.Price = bouquet.TotalPrice;
                }
            }
        }

        public async Task<CartItemResponse?> IncreaseQuantityAsync(int id)
        {
            var cartItem = await _context.CartItems
                .Include(ci => ci.Product)
                    .ThenInclude(p => p.Images)
                .Include(ci => ci.CustomBouquet)
                .FirstOrDefaultAsync(ci => ci.Id == id);

            if (cartItem == null)
                return null;

            cartItem.Quantity += 1;
            await _context.SaveChangesAsync();

            return MapToResponse(cartItem);
        }

        public async Task<(CartItemResponse? response, bool removed)> DecreaseQuantityAsync(int id)
        {
            var cartItem = await _context.CartItems
                .Include(ci => ci.Product)
                    .ThenInclude(p => p.Images)
                .Include(ci => ci.CustomBouquet)
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

            return (MapToResponse(cartItem), false);
        }

        protected override CartItemResponse MapToResponse(CartItem entity)
        {
            return new CartItemResponse
            {
                Id = entity.Id,
                ProductId = entity.ProductId ?? 0,
                ProductName = GetItemName(entity),
                Price = GetItemPrice(entity),
                Quantity = entity.Quantity,
                CardMessage = entity.CardMessage,
                SpecialInstructions = entity.SpecialInstructions,
                ImageUrl = GetItemImageUrl(entity)
            };
        }

        private string GetItemName(CartItem item)
        {
            if (item.Product != null)
                return item.Product.Name;

            if (item.CustomBouquet != null)
                return "Custom bouquet";

            return item.ProductName ?? "Unknown Item";
        }

        private decimal GetItemPrice(CartItem item)
        {
            if (item.Product != null)
                return item.Product.Price;

            if (item.CustomBouquet != null)
                return item.CustomBouquet.TotalPrice;

            return item.Price;
        }

        private string GetItemImageUrl(CartItem item)
        {
            if (item.Product?.Images != null)
                return item.Product.Images.FirstOrDefault()?.ImageUrl;

            return item.ImageUrl;
        }
    }
}
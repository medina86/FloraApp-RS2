using Flora.Models.Recommendations;
using Flora.Models.Responses;
using Flora.Services.Database;
using Flora.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Services.Services
{
    public class RecommendationService : IRecommendationService
    {
        private readonly FLoraDbContext _context;
        private readonly ILogger<RecommendationService> _logger;
        private Dictionary<(int, int), double> _similarityMap;

        public RecommendationService(FLoraDbContext context, ILogger<RecommendationService> logger)
        {
            _context = context;
            _logger = logger;
            _similarityMap = new Dictionary<(int, int), double>();
        }
        public async Task<List<ProductResponse>> GetRecommendedProductsAsync(int productId, int topN = 5)
        {
            try
            {
                if (_similarityMap.Count == 0)
                {
                    await RecalculateSimilarityMapAsync();
                }

                var recommendedProductIds = _similarityMap
                    .Where(kv => kv.Key.Item1 == productId)
                    .OrderByDescending(kv => kv.Value)
                    .Take(topN)
                    .Select(kv => kv.Key.Item2)
                    .ToList();

                var products = await _context.Products
                    .Where(p => recommendedProductIds.Contains(p.Id) && p.IsAvailable && p.Active)
                    .Include(p => p.Images)
                    .Include(p => p.Category)
                    .Include(p => p.Occasion)
                    .ToListAsync();

                var result = recommendedProductIds
                    .Select(id => products.FirstOrDefault(p => p.Id == id))
                    .Where(p => p != null)
                    .Select(p => new ProductResponse
                    {
                        Id = p.Id,
                        Name = p.Name,
                        Description = p.Description,
                        Price = p.Price,
                        IsNew = p.IsNew,
                        IsFeatured = p.IsFeatured,
                        CategoryId = p.CategoryId,
                        CategoryName = p.Category?.Name,
                        OccasionId = p.OccasionId,
                        OccasionName = p.Occasion?.Name,
                        Active = p.Active,
                        IsAvailable = p.IsAvailable,
                        ImageUrls = p.Images.Select(i => i.ImageUrl).ToList()
                    })
                    .ToList();

                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Greška prilikom dohvaćanja preporučenih proizvoda za proizvod ID: {ProductId}", productId);
                return new List<ProductResponse>();
            }
        }
        public async Task<List<ProductCoPurchase>> GetCoPurchaseMapAsync()
        {
            try
            {
                var coPurchases = await _context.OrderDetails
                    .Include(od => od.Order)
                    .AsNoTracking()
                    .GroupBy(od => od.OrderId)
                    .Select(orderGroup => new
                    {
                        OrderId = orderGroup.Key,
                        Products = orderGroup.Select(od => od.ProductId).Where(id => id.HasValue).Select(id => id.Value).ToList()
                    })
                    .ToListAsync();

                var productPairs = new List<(int, int)>();
                foreach (var order in coPurchases)
                {
                    for (int i = 0; i < order.Products.Count; i++)
                    {
                        for (int j = 0; j < order.Products.Count; j++)
                        {
                            if (i != j)
                            {
                                productPairs.Add((order.Products[i], order.Products[j]));
                            }
                        }
                    }
                }

                var result = productPairs
                    .GroupBy(pair => pair)
                    .Select(g => new ProductCoPurchase
                    {
                        ProductId = g.Key.Item1,
                        CoPurchasedProductId = g.Key.Item2,
                        Count = g.Count()
                    })
                    .ToList();

                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Greška prilikom generiranja mape ko-kupovina");
                return new List<ProductCoPurchase>();
            }
        }
        public async Task RecalculateSimilarityMapAsync()
        {
            try
            {
                _logger.LogInformation("Započinje izračun mape sličnosti proizvoda");
                
                var userProductPurchases = await _context.OrderDetails
                    .Include(od => od.Order)
                    .Where(od => od.ProductId.HasValue)
                    .AsNoTracking()
                    .Select(od => new
                    {
                        UserId = od.Order.UserId,
                        ProductId = od.ProductId.Value
                    })
                    .Distinct()
                    .ToListAsync();

                var productUserMap = userProductPurchases
                    .GroupBy(p => p.ProductId)
                    .ToDictionary(g => g.Key, g => g.Select(p => p.UserId).ToHashSet());

                _similarityMap = new Dictionary<(int, int), double>();

                var productIds = productUserMap.Keys.ToList();
                for (int i = 0; i < productIds.Count; i++)
                {
                    for (int j = 0; j < productIds.Count; j++)
                    {
                        if (i == j) continue;

                        int productA = productIds[i];
                        int productB = productIds[j];

                        var usersA = productUserMap[productA];
                        var usersB = productUserMap[productB];

                        var intersection = usersA.Intersect(usersB).Count();
                        var union = usersA.Count + usersB.Count - intersection;

                        if (union == 0) continue;

                        double similarity = (double)intersection / union;
                        _similarityMap[(productA, productB)] = similarity;
                    }
                }

                _logger.LogInformation("Izračun mape sličnosti proizvoda uspješno završen. Ukupno parova: {Count}", _similarityMap.Count);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Greška prilikom izračunavanja mape sličnosti proizvoda");
            }
        }

        public async Task<List<ProductResponse>> GetRecommendedForUserAsync(int userId, int maxResults = 10)
        {
            try
            {
                // Provjerimo ima li korisnik narudžbe
                var hasOrders = await _context.Orders.AnyAsync(o => o.UserId == userId);
                
                if (!hasOrders)
                {
                    // Ako korisnik nema narudžbe, vraćamo popularne/featured proizvode
                    return await GetFeaturedProductsAsync(maxResults);
                }

                // Dohvati zadnje 3 narudžbe korisnika
                var lastOrders = await _context.Orders
                    .Where(o => o.UserId == userId)
                    .OrderByDescending(o => o.OrderDate)
                    .Include(o => o.OrderDetails)
                    .Take(3)
                    .ToListAsync();

                var recommendedIds = new HashSet<int>();

                // Za svaki proizvod iz posljednjih narudžbi, dohvati preporuke
                foreach (var order in lastOrders)
                {
                    foreach (var item in order.OrderDetails.Where(od => od.ProductId.HasValue))
                    {
                        var recommendations = await GetRecommendedProductsAsync(item.ProductId.Value, 3);
                        foreach (var product in recommendations)
                            recommendedIds.Add(product.Id);

                        // Dodajemo i sam proizvod koji je korisnik kupio u preporuke ako ga nema u setu
                        if (!recommendedIds.Contains(item.ProductId.Value))
                            recommendedIds.Add(item.ProductId.Value);
                    }
                }

                // Dohvati sve preporučene proizvode odjednom
                var recommendedProducts = await _context.Products
                    .Where(p => recommendedIds.Contains(p.Id) && p.IsAvailable && p.Active)
                    .Include(p => p.Images)
                    .Include(p => p.Category)
                    .Include(p => p.Occasion)
                    .Take(maxResults)
                    .ToListAsync();

                // Mapiraj u DTO
                var result = recommendedProducts.Select(p => new ProductResponse
                {
                    Id = p.Id,
                    Name = p.Name,
                    Description = p.Description,
                    Price = p.Price,
                    IsNew = p.IsNew,
                    IsFeatured = p.IsFeatured,
                    CategoryId = p.CategoryId,
                    CategoryName = p.Category?.Name,
                    OccasionId = p.OccasionId,
                    OccasionName = p.Occasion?.Name,
                    Active = p.Active,
                    IsAvailable = p.IsAvailable,
                    ImageUrls = p.Images.Select(i => i.ImageUrl).ToList()
                }).ToList();

                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Greška prilikom dohvaćanja preporučenih proizvoda za korisnika ID: {UserId}", userId);
                return new List<ProductResponse>();
            }
        }

        private async Task<List<ProductResponse>> GetFeaturedProductsAsync(int count)
        {
            // Vraća popularne/featured proizvode za korisnike koji nemaju narudžbe
            var featuredProducts = await _context.Products
                .Where(p => p.IsAvailable && p.Active && (p.IsFeatured || p.IsNew))
                .Include(p => p.Images)
                .Include(p => p.Category)
                .Include(p => p.Occasion)
                .Take(count)
                .ToListAsync();

            return featuredProducts.Select(p => new ProductResponse
            {
                Id = p.Id,
                Name = p.Name,
                Description = p.Description,
                Price = p.Price,
                IsNew = p.IsNew,
                IsFeatured = p.IsFeatured,
                CategoryId = p.CategoryId,
                CategoryName = p.Category?.Name,
                OccasionId = p.OccasionId,
                OccasionName = p.Occasion?.Name,
                Active = p.Active,
                IsAvailable = p.IsAvailable,
                ImageUrls = p.Images.Select(i => i.ImageUrl).ToList()
            }).ToList();
        }
    }
}

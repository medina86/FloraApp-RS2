using Flora.Models.Recommendations;
using Flora.Models.Responses;
using Flora.Services.Database;
using Flora.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.ML.Trainers;
using Microsoft.ML;
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
                _logger.LogInformation("Započinje treniranje ML.NET item-based preporuka");

                var userProductPurchases = await _context.OrderDetails
                    .Include(od => od.Order)
                    .Where(od => od.ProductId.HasValue)
                    .AsNoTracking()
                    .Select(od => new RecommendationInput
                    {
                        userId = od.Order.UserId.ToString(),
                        productId = od.ProductId.Value.ToString(),
                        Label = 1f 
                    })
                    .ToListAsync();

                var mlContext = new MLContext();

                var dataView = mlContext.Data.LoadFromEnumerable(userProductPurchases);

                var options = new MatrixFactorizationTrainer.Options
                {
                    MatrixColumnIndexColumnName = nameof(RecommendationInput.userId),
                    MatrixRowIndexColumnName = nameof(RecommendationInput.productId),
                    LabelColumnName = nameof(RecommendationInput.Label),
                    NumberOfIterations = 20,
                    ApproximationRank = 100
                };

                var pipeline = mlContext.Recommendation().Trainers.MatrixFactorization(options);

                var model = pipeline.Fit(dataView);

                var predictionEngine = mlContext.Model.CreatePredictionEngine<RecommendationInput, RecommendationPrediction>(model);

                _similarityMap = new Dictionary<(int, int), double>();
                var productIds = userProductPurchases.Select(p => int.Parse(p.productId)).Distinct().ToList();

                foreach (var p1 in productIds)
                {
                    foreach (var p2 in productIds)
                    {
                        if (p1 == p2) continue;

                        var prediction = predictionEngine.Predict(new RecommendationInput
                        {
                            userId = p1.ToString(),
                            productId = p2.ToString()
                        });

                        _similarityMap[(p1, p2)] = prediction.Score;
                    }
                }

                _logger.LogInformation("ML.NET sličnosti proizvoda izračunate. Ukupno parova: {Count}", _similarityMap.Count);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Greška prilikom izračunavanja ML.NET sličnosti proizvoda");
            }
        }

        public async Task<List<ProductResponse>> GetRecommendedForUserAsync(int userId, int maxResults = 10)
        {
            try
            {
                var hasOrders = await _context.Orders.AnyAsync(o => o.UserId == userId);
                
                if (!hasOrders)
                {
                    return await GetFeaturedProductsAsync(maxResults);
                }

                var lastOrders = await _context.Orders
                    .Where(o => o.UserId == userId)
                    .OrderByDescending(o => o.OrderDate)
                    .Include(o => o.OrderDetails)
                    .Take(3)
                    .ToListAsync();

                var recommendedIds = new HashSet<int>();

                foreach (var order in lastOrders)
                {
                    foreach (var item in order.OrderDetails.Where(od => od.ProductId.HasValue))
                    {
                        var recommendations = await GetRecommendedProductsAsync(item.ProductId.Value, 3);
                        foreach (var product in recommendations)
                            recommendedIds.Add(product.Id);

                        if (!recommendedIds.Contains(item.ProductId.Value))
                            recommendedIds.Add(item.ProductId.Value);
                    }
                }

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
    public class RecommendationInput
    {
        public string userId { get; set; }
        public string productId { get; set; }
        public float Label { get; set; }
    }

    public class RecommendationPrediction
    {
        public float Score { get; set; }
    }

}

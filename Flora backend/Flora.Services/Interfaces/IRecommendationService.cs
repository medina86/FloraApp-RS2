using Flora.Models.Recommendations;
using Flora.Models.Responses;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Services.Interfaces
{
    public interface IRecommendationService
    {
        Task<List<ProductResponse>> GetRecommendedProductsAsync(int productId, int topN = 5);
        Task<List<ProductCoPurchase>> GetCoPurchaseMapAsync();
        Task RecalculateSimilarityMapAsync();
        Task<List<ProductResponse>> GetRecommendedForUserAsync(int userId, int maxResults = 10);
    }
}

using Flora.Services.Database;
using Flora.Models.SearchObjects;
using Flora.Models.Responses;
using System.Collections.Generic;
using System.Threading.Tasks;


namespace Flora.Services.Interfaces
{
    public interface IService<T, TSearch> where T : class where TSearch : BaseSearchObject
    {
        Task<PagedResult<T>> GetAsync(TSearch search);
        Task<T?> GetByIdAsync(int id);
    }
}
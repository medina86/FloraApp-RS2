
using Flora.Models.Requests;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using Flora.Services.Database;

namespace Flora.Services.Interfaces
{
    public interface IOccasionService : ICRUDService<OccasionResponse, OccasionSearchObject, OccasionRequest, OccasionRequest>
    {
        Task<List<Database.Occasion>> GetAllAsync();
    }
}


using Flora.Services.Database;

public interface IOccasionService
{
    Task<List<Occasion>> GetAllAsync();
}

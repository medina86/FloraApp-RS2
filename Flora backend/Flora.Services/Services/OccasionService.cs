using Flora.Services.Database;
using Microsoft.EntityFrameworkCore;

public class OccasionService : IOccasionService
{
    private readonly FLoraDbContext _context;

    public OccasionService(FLoraDbContext context)
    {
        _context = context;
    }

    public async Task<List<Occasion>> GetAllAsync()
    {
        return await _context.Occasions
            .Select(o => new Occasion
            {
                OccasionId = o.OccasionId,
                Name = o.Name
            })
            .ToListAsync();
    }
}

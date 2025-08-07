using Mapster;
using MapsterMapper;
using Flora.Models.Requests;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using Flora.Services.Database;
using Flora.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Services.Services
{
    public class OccasionService : BaseCRUDService<OccasionResponse, OccasionSearchObject, Database.Occasion, OccasionRequest, OccasionRequest>, IOccasionService
    {
        public OccasionService(FLoraDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public async Task<List<Database.Occasion>> GetAllAsync()
        {
            return await _context.Occasions.ToListAsync();
        }

            protected override IQueryable<Occasion> ApplyFilter(IQueryable<Occasion> query, OccasionSearchObject searchObject = null)
        {
            var filteredQuery = base.ApplyFilter(query, searchObject);

            if (!string.IsNullOrWhiteSpace(searchObject?.Name))
            {
                filteredQuery = filteredQuery.Where(x => x.Name.ToLower().Contains(searchObject.Name.ToLower()));
            }

            return filteredQuery;
        }
    }
}

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
    public class DecorationSelectionService : BaseCRUDService<DecorationSelectionResponse, DecorationSelectionSearchObject, DecorationSelection, DecorationSelectionRequest, DecorationSelectionRequest>, IDecorationSelectionService
    {
        private readonly FLoraDbContext _context;
        private readonly IMapper _mapper;

        public DecorationSelectionService(FLoraDbContext context, IMapper mapper)
            : base(context, mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public override async Task<DecorationSelectionResponse> CreateAsync(DecorationSelectionRequest request)
        {
            var existingSelection = await _context.DecorationSelections
                .FirstOrDefaultAsync(ds => ds.DecorationRequestId == request.DecorationRequestId);

            if (existingSelection != null)
            {
                existingSelection.DecorationSuggestionId = request.DecorationSuggestionId;
                existingSelection.Comments = request.Comments;
                existingSelection.CreatedAt = DateTime.Now;
                
                await _context.SaveChangesAsync();
                return _mapper.Map<DecorationSelectionResponse>(existingSelection);
            }
            else
            {
                var entity = new DecorationSelection
                {
                    DecorationRequestId = request.DecorationRequestId,
                    DecorationSuggestionId = request.DecorationSuggestionId,
                    UserId = request.UserId,
                    Comments = request.Comments,
                    CreatedAt = DateTime.Now,
                    Status = "Selected"
                };

                _context.DecorationSelections.Add(entity);
                await _context.SaveChangesAsync();
                return _mapper.Map<DecorationSelectionResponse>(entity);
            }
        }

        public async Task<DecorationSelectionResponse> GetSelectionByRequestId(int decorationRequestId)
        {
            var entity = await _context.DecorationSelections
                .Include(ds => ds.DecorationSuggestion)
                .FirstOrDefaultAsync(ds => ds.DecorationRequestId == decorationRequestId);

            if (entity == null)
                return null;

            return _mapper.Map<DecorationSelectionResponse>(entity);
        }

        protected override IQueryable<DecorationSelection> ApplyFilter(IQueryable<DecorationSelection> query, DecorationSelectionSearchObject search)
        {
            if (search?.DecorationRequestId != null)
            {
                query = query.Where(ds => ds.DecorationRequestId == search.DecorationRequestId);
            }

            if (search?.UserId != null)
            {
                query = query.Where(ds => ds.UserId == search.UserId);
            }
            
            if (search?.DecorationSuggestionId != null)
            {
                query = query.Where(ds => ds.DecorationSuggestionId == search.DecorationSuggestionId);
            }
            
            if (!string.IsNullOrWhiteSpace(search?.Status))
            {
                query = query.Where(ds => ds.Status == search.Status);
            }
            
            if (!string.IsNullOrWhiteSpace(search?.FTS))
            {
                query = query.Where(ds => 
                    ds.Comments.Contains(search.FTS) ||
                    ds.Status.Contains(search.FTS));
            }

            return query;
        }
    }
}

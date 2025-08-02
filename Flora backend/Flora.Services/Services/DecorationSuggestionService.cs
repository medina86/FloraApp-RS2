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
    public class DecorationSuggestionService : BaseCRUDService<DecorationSuggestionResponse, DecorationSuggestionSearchObject, DecorationSuggestion, DecorationSuggestionRequest, DecorationSuggestionRequest>, IDecorationSuggestionService
    {
        private readonly IBlobService _blobService;

        public DecorationSuggestionService(FLoraDbContext context, IMapper mapper, IBlobService blobService)
            : base(context, mapper)
        {
            _blobService = blobService;
        }

        public override async Task<DecorationSuggestionResponse> CreateAsync(DecorationSuggestionRequest request)
        {
            var imageUrl = await _blobService.UploadFileAsync(request.Image);
            var entity = new DecorationSuggestion
            {
                DecorationRequestId = request.DecorationRequestId,
                Description = request.Description,
                ImageUrl = imageUrl
            };
            _context.DecorationSuggestions.Add(entity);
            await _context.SaveChangesAsync();
            return _mapper.Map<DecorationSuggestionResponse>(entity);
        }

        public override async Task<DecorationSuggestionResponse?> UpdateAsync(int id, DecorationSuggestionRequest request)
        {
            var entity = await _context.DecorationSuggestions.FindAsync(id);
            if (entity == null) return null;

            entity.Description = request.Description;
            entity.DecorationRequestId = request.DecorationRequestId;

            if (request.Image != null)
            {
                entity.ImageUrl = await _blobService.UploadFileAsync(request.Image);
            }

            await _context.SaveChangesAsync();
            return _mapper.Map<DecorationSuggestionResponse>(entity);
        }


    }
}

using Flora.Models.Requests;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using Flora.Services.Database;
using Flora.Services.Interfaces;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;

namespace Flora.Services.Services
{
    public class DecorationRequestService : BaseCRUDService<DecorationRequestResponse, DecorationRequestSearchObject, DecorationRequest, DecorationRequestRequest, DecorationRequestRequest>,
         IDecorationRequestService
    {
        public DecorationRequestService(FLoraDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        protected override IQueryable<DecorationRequest> ApplyFilter(IQueryable<DecorationRequest> query, DecorationRequestSearchObject search)
        {
            if (search?.UserId.HasValue == true)
            {
                query = query.Where(dr => dr.UserId == search.UserId.Value);
            }

            return query;
        }
    }
}

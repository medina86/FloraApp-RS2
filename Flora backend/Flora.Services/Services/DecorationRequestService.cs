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

namespace Flora.Services.Services
{
    public class DecorationRequestService : BaseCRUDService<DecorationRequestResponse, DecorationRequestSearchObject, DecorationRequest, DecorationRequestRequest, DecorationRequestRequest>,
         IDecorationRequestService
    {
        public DecorationRequestService(FLoraDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }
    }
}

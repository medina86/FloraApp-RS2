using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Requests
{
    public class DecorationSuggestionRequest
    {
        public int DecorationRequestId { get; set; }
        public IFormFile Image { get; set; } = default!;
        public string? Description { get; set; }
    }
}

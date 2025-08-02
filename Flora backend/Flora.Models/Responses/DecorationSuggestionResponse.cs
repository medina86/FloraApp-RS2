using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Responses
{
    public class DecorationSuggestionResponse
    {
        public int Id { get; set; }
        public int DecorationRequestId { get; set; }
        public string ImageUrl { get; set; } = string.Empty;
        public string? Description { get; set; }
    }
}

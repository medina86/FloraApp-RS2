using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Services.Database
{
    public class DecorationSuggestion
    {
        public int Id { get; set; }

        public int DecorationRequestId { get; set; }

        public DecorationRequest DecorationRequest { get; set; } = null!;

        public string ImageUrl { get; set; } = string.Empty;

        public string? Description { get; set; }
    }

}

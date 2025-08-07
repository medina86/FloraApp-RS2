using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Responses
{
    public class DecorationSelectionResponse
    {
        public int Id { get; set; }
        public int DecorationRequestId { get; set; }
        public int DecorationSuggestionId { get; set; }
        public int UserId { get; set; }
        public string? Comments { get; set; }
        public DateTime CreatedAt { get; set; }
        public string Status { get; set; } = "Selected";
    }
}

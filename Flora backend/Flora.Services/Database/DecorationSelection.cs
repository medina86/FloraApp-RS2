using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Services.Database
{
    public class DecorationSelection
    {
        public int Id { get; set; }
        public int DecorationRequestId { get; set; }
        public DecorationRequest DecorationRequest { get; set; } = null!;
        public int DecorationSuggestionId { get; set; }
        public DecorationSuggestion DecorationSuggestion { get; set; } = null!;
        public int UserId { get; set; }
        public User User { get; set; } = null!;
        public string? Comments { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public string Status { get; set; } = "Selected";
    }
}

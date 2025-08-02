using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Services.Database
{
    public class DecorationRequest
    {
        public int Id { get; set; }

        public string EventType { get; set; } = string.Empty;

        public DateTime EventDate { get; set; }

        public string VenueType { get; set; } = string.Empty;

        public int NumberOfGuests { get; set; }

        public int NumberOfTables { get; set; }

        public string ThemeOrColors { get; set; } = string.Empty;

        public string Location { get; set; } = string.Empty;

        public string? SpecialRequests { get; set; }

        public decimal Budget { get; set; }

        public int UserId { get; set; }  // Ako imaš korisnike

        public User? User { get; set; }

        public ICollection<DecorationSuggestion> Suggestions { get; set; } = new List<DecorationSuggestion>();
    }

}

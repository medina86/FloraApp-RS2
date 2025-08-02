using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Requests
{
    public class DecorationRequestRequest
    {
        public string EventType { get; set; }
        public DateTime EventDate { get; set; }
        public string VenueType { get; set; }
        public int NumberOfGuests { get; set; }
        public int NumberOfTables { get; set; }
        public string ThemeOrColors { get; set; }
        public string Location { get; set; }
        public string? SpecialRequests { get; set; }
        public decimal Budget { get; set; }
        public int UserId { get; set; }
    }
}

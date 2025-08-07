using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Requests
{
    public class DecorationRequestRequest
    {
        [Required(ErrorMessage = "Event type is required")]
        public string EventType { get; set; } = string.Empty;
        
        [Required(ErrorMessage = "Event date is required")]
        public DateTime EventDate { get; set; }
        
        [Required(ErrorMessage = "Venue type is required")]
        public string VenueType { get; set; } = string.Empty;
        
        [Required(ErrorMessage = "Number of guests is required")]
        [Range(1, int.MaxValue, ErrorMessage = "Number of guests must be greater than 0")]
        public int NumberOfGuests { get; set; }
        
        [Required(ErrorMessage = "Number of tables is required")]
        [Range(0, int.MaxValue, ErrorMessage = "Number of tables must be a positive number")]
        public int NumberOfTables { get; set; }
        
        [Required(ErrorMessage = "Theme or colors is required")]
        public string ThemeOrColors { get; set; } = string.Empty;
        
        [Required(ErrorMessage = "Location is required")]
        public string Location { get; set; } = string.Empty;
        
        public string? SpecialRequests { get; set; }
        
        [Required(ErrorMessage = "Budget is required")]
        [Range(0, double.MaxValue, ErrorMessage = "Budget must be a positive number")]
        public decimal Budget { get; set; }
        
        [Required(ErrorMessage = "User ID is required")]
        public int UserId { get; set; }
    }
}

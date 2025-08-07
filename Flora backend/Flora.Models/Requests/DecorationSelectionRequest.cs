using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Requests
{
    public class DecorationSelectionRequest
    {
        [Required(ErrorMessage = "Decoration request is required")]
        public int DecorationRequestId { get; set; }
        
        [Required(ErrorMessage = "Decoration suggestion is required")]
        public int DecorationSuggestionId { get; set; }
        
        [Required(ErrorMessage = "User is required")]
        public int UserId { get; set; }
        
        public string? Comments { get; set; }
    }
}

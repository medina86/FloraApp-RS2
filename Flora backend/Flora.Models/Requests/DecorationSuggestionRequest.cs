using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Requests
{
    public class DecorationSuggestionRequest
    {
        [Required(ErrorMessage = "Decoration request ID is required")]
        public int DecorationRequestId { get; set; }
        
        [Required(ErrorMessage = "Decoration image is required")]
        public IFormFile Image { get; set; } = default!;
        
        public string? Description { get; set; }
    }
}

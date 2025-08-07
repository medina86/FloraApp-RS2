using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Requests
{
    public class OccasionRequest
    {
        [Required(ErrorMessage = "Occasion name is required")]
        [MaxLength(100, ErrorMessage = "Occasion name cannot exceed 100 characters")]
        public string Name { get; set; } = string.Empty;
    }
}

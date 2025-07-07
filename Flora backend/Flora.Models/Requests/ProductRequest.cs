using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Requests
{
    public class ProductRequest
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        [Required]
        [Range(0, 10000)]
        public decimal Price { get; set; }
        public int? CategoryId { get; set; }
        public List<string>? Images { get; set; }
        public bool IsNew { get; set; } = false;
        public bool IsFeatured { get; set; } = false;
        public int? OccasionId { get; set; }
        public bool Active { get; set; } = true;
        public bool IsAvailable { get; set; } = true;
    }

}

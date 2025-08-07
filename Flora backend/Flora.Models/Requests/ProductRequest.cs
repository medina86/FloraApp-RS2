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
        [Required(ErrorMessage = "Product name is required")]
        [MaxLength(100, ErrorMessage = "Name cannot exceed 100 characters")]
        public string Name { get; set; } = string.Empty;
        
        [MaxLength(500, ErrorMessage = "Description cannot exceed 500 characters")]
        public string? Description { get; set; }
        
        [Required(ErrorMessage = "Price is required")]
        [Range(0.01, 10000.00, ErrorMessage = "Price must be between 0.01 and 10,000.00")]
        public decimal Price { get; set; }
        
        [Required(ErrorMessage = "Category is required")]
        [Display(Name = "Category")]
        public int CategoryId { get; set; }
        
        public List<string>? Images { get; set; }
        
        public bool IsNew { get; set; } = false;
        
        public bool IsFeatured { get; set; } = false;
        
        [Display(Name = "Occasion")]
        public int? OccasionId { get; set; }
        
        public bool Active { get; set; } = true;
        
        public bool IsAvailable { get; set; } = true;
    }
}

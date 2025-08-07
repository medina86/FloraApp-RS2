using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Requests
{
    public class BlogPostRequest
    {
        [Required(ErrorMessage = "Blog title is required")]
        [MaxLength(200, ErrorMessage = "Title cannot exceed 200 characters")]
        public string Title { get; set; } = string.Empty;
        
        [Required(ErrorMessage = "Blog content is required")]
        public string Content { get; set; } = string.Empty;
        
        public List<IFormFile> Images { get; set; } = new();
    }

}

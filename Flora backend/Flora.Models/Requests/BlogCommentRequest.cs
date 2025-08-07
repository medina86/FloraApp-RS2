using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Requests
{
    public class BlogCommentRequest
    {
        [Required(ErrorMessage = "Blog post ID is required")]
        public int BlogPostId { get; set; }
        
        [Required(ErrorMessage = "User ID is required")]
        public int UserId {  get; set; }
        
        [Required(ErrorMessage = "Comment content is required")]
        [MaxLength(500, ErrorMessage = "Comment cannot exceed 500 characters")]
        public string Content { get; set; } = string.Empty;
    }

}

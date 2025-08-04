using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Requests
{
    public class BlogCommentRequest
    {
        public int BlogPostId { get; set; }
        public int UserId {  get; set; }
        public string Content { get; set; } = string.Empty;
    }

}

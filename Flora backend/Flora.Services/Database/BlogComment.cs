using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Services.Database
{
    public class BlogComment
    {
        public int Id { get; set; }
        public string AuthorName { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public int BlogPostId { get; set; }
        public virtual BlogPost BlogPost { get; set; } = null!;

        public int UserId { get; set; } 
        public virtual User? User { get; set; }
    }

}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Services.Database
{
    public class BlogImage
    {
        public int Id { get; set; }
        public string Url { get; set; } = string.Empty;

        public int BlogPostId { get; set; }
        public virtual BlogPost BlogPost { get; set; } = null!;
    }

}

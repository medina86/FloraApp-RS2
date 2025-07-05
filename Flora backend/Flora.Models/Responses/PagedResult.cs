using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Responses
{
    public class PagedResult<T>
    {
        public List<T> Items { get; set; } = new List<T>();
        public int? TotalCount { get; set; }
    }
}

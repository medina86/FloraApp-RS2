using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.SearchObjects
{
    public class ProductSearchObject:BaseSearchObject
    {
        public string? Name { get; set; } 
        public int? CategoryId { get; set; } 
        public decimal? MinPrice { get; set; }
        public decimal? MaxPrice { get; set; }
        public bool Active { get; set; }
        public bool IsAvailable { get; set; }
    }
}
